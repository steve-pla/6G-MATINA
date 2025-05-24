%% Massive MIMO MU-MIMO Simulation with Beamforming (Sub-6 GHz, 4-Antenna UEs)
clc; clear; close all;

%% System Parameters
fc = 3.5e9; % Carrier frequency (3.5 GHz)
BW = 100e6; % Bandwidth (100 MHz)
N0 = -174 + 10*log10(BW); % Noise Power in dBm
Ptx_dBm = 40; % BS Transmit Power (dBm)
Ptx = 10^((Ptx_dBm - 30)/10); % Convert to Watts
M_values = [32, 64, 128]; % Number of BS Antennas
K = 10; % Number of Users
Nr = 4; % Number of antennas per UE
cell_radius = 500; % meters

%% Generate User Locations (Randomly Distributed)
user_positions = cell_radius * (rand(K, 2) - 0.5);

%% Path Loss Model (Urban Macro, 3GPP TR 38.901)
PL_dB = 128.1 + 37.6*log10(sqrt(sum(user_positions.^2, 2))/1000); % dB
PL = 10.^(-PL_dB/10); % Linear Scale

%% Loop Over Different MIMO Antenna Configurations
results = struct();
for M = M_values
    
    %% Generate Rayleigh Fading Channel Matrix (K x M x Nr)
    H = (randn(K, M, Nr) + 1j*randn(K, M, Nr)) / sqrt(2);
    
    %% Apply Path Loss
    for k = 1:K
        H(k, :, :) = H(k, :, :) * sqrt(PL(k));
    end
    
    %% Scenario 1: Without Beamforming (Omnidirectional Transmission)
    SINR_without_BF = zeros(K, 1);
    for k = 1:K
        H_k = reshape(H(k, :, :), M * Nr, 1);  % Reshape H(k, :, :) to a column vector
        signal_power = abs(H_k' * H_k) * Ptx;  % Omnidirectional signal power calculation
        
        % Correct interference power computation
        interference_power = 0;
        for i = 1:K
            if i ~= k  % Exclude current user
                H_i = reshape(H(i, :, :), M * Nr, 1);
                interference_power = interference_power + abs(H_k' * H_i).^2 * Ptx;
            end
        end
        
        noise_power = 10^(N0/10); % Noise power from N0
        SINR_without_BF(k) = signal_power / (interference_power + noise_power); % SINR calculation
    end
    Capacity_without_BF = BW * log2(1 + SINR_without_BF) / 1e9; % in Gbps
    SumRate_without_BF = sum(Capacity_without_BF); % Total Capacity
    
    %% Scenario 2: With Beamforming (Zero-Forcing and MMSE)
    %% Zero-Forcing (ZF) Beamforming
    H_eff = reshape(H, K, M*Nr); % Effective Channel Matrix
    W_zf = (H_eff' / (H_eff * H_eff')); % Pseudo-inverse
    W_zf = W_zf ./ vecnorm(W_zf, 2, 1); % Normalize
    
    %% Minimum Mean Square Error (MMSE) Beamforming
    sigma2 = 10^(N0/10); % Noise power

    % Compute MMSE beamforming matrix
    W_mmse = (H_eff' * H_eff + sigma2 * eye(M * Nr)) \ (H_eff'); % MMSE Beamforming
    
    %% Compute SINR for Each User for MMSE
    SINR_zf = zeros(K, 1);
    SINR_mmse = zeros(K, 1);
    
    for k = 1:K
        % ZF SINR Calculation
        signal_power_zf = abs(H_eff(k, :) * W_zf(:, k)).^2 * Ptx;
        interference_power_zf = sum(abs(H_eff(k, :) * W_zf).^2, 2) * Ptx - signal_power_zf;
        SINR_zf(k) = signal_power_zf / (interference_power_zf + sigma2);

        % MMSE SINR Calculation
        signal_power_mmse = abs(H_eff(k, :) * W_mmse(:, k)).^2 * Ptx;
        interference_power_mmse = sum(abs(H_eff(k, :) * W_mmse).^2, 2) * Ptx - signal_power_mmse;
        SINR_mmse(k) = signal_power_mmse / (interference_power_mmse + sigma2);
    end
    
    %% Compute Shannon Capacity
    Capacity_zf = BW * log2(1 + SINR_zf) / 1e9; % in Gbps
    Capacity_mmse = BW * log2(1 + SINR_mmse) / 1e9; % in Gbps
    SumRate_zf = sum(Capacity_zf); % Total Capacity for ZF
    SumRate_mmse = sum(Capacity_mmse); % Total Capacity for MMSE
    
    %% Store Results
    results.(sprintf('M%d', M)) = struct(...
        'SINR_without_BF', SINR_without_BF, 'Capacity_without_BF', Capacity_without_BF, 'SumRate_without_BF', SumRate_without_BF, ...
        'SINR_zf', SINR_zf, 'Capacity_zf', Capacity_zf, 'SumRate_zf', SumRate_zf, ...
        'SINR_mmse', SINR_mmse, 'Capacity_mmse', Capacity_mmse, 'SumRate_mmse', SumRate_mmse);
    
    fprintf('M = %d | Sum-Rate without BF: %.2f Gbps | Sum-Rate ZF: %.2f Gbps | Sum-Rate MMSE: %.2f Gbps\n', M, SumRate_without_BF, SumRate_zf, SumRate_mmse);
end

%% Plot Results
%% Plot Results
figure;
for M = M_values
    plot(10*log10(results.(sprintf('M%d', M)).SINR_without_BF), 'o-', 'DisplayName', sprintf('Without BF M = %d', M)); hold on;
    plot(10*log10(results.(sprintf('M%d', M)).SINR_zf), 's-', 'DisplayName', sprintf('ZF M = %d', M)); hold on;
    plot(10*log10(results.(sprintf('M%d', M)).SINR_mmse), 'x-', 'DisplayName', sprintf('MMSE M = %d', M)); hold on;
end
xlabel('User Index'); ylabel('SINR (dB)'); title('SINR Comparison: Without Beamforming, ZF, MMSE');
legend; grid on;

% Sum-Rate Bar Plot
sumRates = zeros(3, length(M_values));
for i = 1:length(M_values)
    sumRates(1, i) = results.(sprintf('M%d', M_values(i))).SumRate_without_BF;
    sumRates(2, i) = results.(sprintf('M%d', M_values(i))).SumRate_zf;
    sumRates(3, i) = results.(sprintf('M%d', M_values(i))).SumRate_mmse;
end

figure;
bar(M_values, sumRates');
legend({'Without BF', 'ZF', 'MMSE'}, 'Location', 'NorthEast');
xlabel('Number of BS Antennas (M)'); ylabel('Sum-Rate (Gbps)'); title('Sum-Rate vs. Number of BS Antennas');
grid on;

clc; clear; close all;

% System Parameters
fc = 3.5e9; % Carrier frequency (3.5 GHz)
BW = 100e6; % Bandwidth (100 MHz)
N0 = -174 + 10*log10(BW); % Noise Power in dBm
Ptx_dBm = 40; % BS Transmit Power (dBm)
Ptx = 10^((Ptx_dBm - 30)/10); % Convert to Watts
M_values = [32, 64, 128]; % Number of BS Antennas
K_values = [10, 40, 80, 100, 120]; % Varying Number of Users
Nr = 4; % Number of antennas per UE
cell_radius = 500; % meters

% Storage for Results
results = struct();

% Loop Over Different MIMO Configurations
for M = M_values
    for K = K_values
        % Generate User Locations (Randomly Distributed)
        user_positions = cell_radius * (rand(K, 2) - 0.5);

        % Path Loss Model (Urban Macro, 3GPP TR 38.901)
        PL_dB = 128.1 + 37.6*log10(sqrt(sum(user_positions.^2, 2))/1000); % dB
        PL = 10.^(-PL_dB/10); % Linear Scale

        % Generate Rayleigh Fading Channel Matrix (K x M x Nr)
        H = (randn(K, M, Nr) + 1j*randn(K, M, Nr)) / sqrt(2);

        % Apply Path Loss
        for k = 1:K
            H(k, :, :) = H(k, :, :) * sqrt(PL(k));
        end

        % Reshape Channel Matrix
        H_eff = reshape(H, K, M * Nr); % Effective Channel Matrix

        % Zero-Forcing (ZF) Beamforming
        W_zf = (H_eff' / (H_eff * H_eff')); % Pseudo-inverse
        W_zf = W_zf ./ vecnorm(W_zf, 2, 1); % Normalize

        % MMSE Beamforming
        H_eff_H_eff = H_eff * H_eff' + eye(K) * 10^(N0/10); % Regularized matrix
        W_mmse = (H_eff' / H_eff_H_eff); % MMSE Beamforming
        W_mmse = W_mmse ./ vecnorm(W_mmse, 2, 1); % Normalize

        % Compute SINR for Each User
        SINR_zf = zeros(K, 1);
        SINR_mmse = zeros(K, 1);
        SINR_noBF = zeros(K, 1); % No Beamforming

        for k = 1:K
            % ZF SINR
            signal_power_zf = abs(H_eff(k, :) * W_zf(:, k)).^2 * Ptx;
            interference_power_zf = sum(abs(H_eff(k, :) * W_zf).^2, 2) * Ptx - signal_power_zf;
            noise_power = 10^(N0/10);
            SINR_zf(k) = signal_power_zf / (interference_power_zf + noise_power);

            % MMSE SINR
            signal_power_mmse = abs(H_eff(k, :) * W_mmse(:, k)).^2 * Ptx;
            interference_power_mmse = sum(abs(H_eff(k, :) * W_mmse).^2, 2) * Ptx - signal_power_mmse;
            SINR_mmse(k) = signal_power_mmse / (interference_power_mmse + noise_power);

            % No Beamforming (Omnidirectional)
            signal_power_noBF = abs(H_eff(k, :) * ones(M * Nr, 1)).^2 * Ptx;
            interference_power_noBF = sum(abs(H_eff(k, :) * ones(M * Nr, 1)).^2, 2) * Ptx - signal_power_noBF;
            SINR_noBF(k) = signal_power_noBF / (interference_power_noBF + noise_power);
        end

        % Compute Shannon Capacity
        Capacity_zf = BW * log2(1 + SINR_zf) / 1e9; % in Gbps
        Capacity_mmse = BW * log2(1 + SINR_mmse) / 1e9; % in Gbps
        Capacity_noBF = BW * log2(1 + SINR_noBF) / 1e9; % in Gbps
        SumRate_zf = sum(Capacity_zf); % Total Capacity
        SumRate_mmse = sum(Capacity_mmse); % Total Capacity
        SumRate_noBF = sum(Capacity_noBF); % Total Capacity

        % Store Results
        results.(sprintf('M%d_K%d', M, K)) = struct('SINR_ZF', SINR_zf, 'SINR_MMSE', SINR_mmse, ...
            'SINR_NoBF', SINR_noBF, 'Capacity_ZF', Capacity_zf, 'Capacity_MMSE', Capacity_mmse, ...
            'Capacity_NoBF', Capacity_noBF, 'SumRate_ZF', SumRate_zf, 'SumRate_MMSE', SumRate_mmse, ...
            'SumRate_NoBF', SumRate_noBF);
    end
end

%% Set figure size
figure('Position', [100, 100, 1200, 800]); % Increase the figure size

% Plot 1: Sum-Rate vs. Number of BS Antennas
subplot(3, 3, 1); % 3x3 grid, first plot
sumRates = arrayfun(@(M) results.(sprintf('M%d_K10', M)).SumRate_ZF, M_values);
bar(M_values, sumRates, 'FaceColor', 'g');
xlabel('Number of BS Antennas (M)');
ylabel('Sum-Rate (Gbps)');
title('Sum-Rate vs. Number of BS Antennas');
grid on;

% Plot 2: SINR Comparison with/without BF
subplot(3, 3, 2);
for M = M_values
    SINR_zf = results.(sprintf('M%d_K10', M)).SINR_ZF;
    SINR_noBF = results.(sprintf('M%d_K10', M)).SINR_NoBF;
    plot(1:length(SINR_zf), 10*log10(SINR_zf), 'o-', 'DisplayName', sprintf('ZF M=%d', M)); hold on;
    plot(1:length(SINR_noBF), 10*log10(SINR_noBF), 'x-', 'DisplayName', sprintf('No BF M=%d', M));
end
xlabel('User Index');
ylabel('SINR (dB)');
title('SINR per User with/without BF');
legend;
grid on;

% Plot 3: Beamforming Gain vs. Number of UEs
subplot(3, 3, 3);
beamforming_gain = zeros(length(K_values), 1);
for i = 1:length(K_values)
    K = K_values(i);
    SINR_zf = results.(sprintf('M128_K%d', K)).SINR_ZF;
    SINR_noBF = results.(sprintf('M128_K%d', K)).SINR_NoBF;
    
    avg_SINR_zf = mean(SINR_zf);
    avg_SINR_noBF = mean(SINR_noBF);
    
    beamforming_gain(i) = 10*log10(avg_SINR_zf / avg_SINR_noBF);
end
bar(K_values, beamforming_gain, 'FaceColor', 'b');
xlabel('Number of UEs');
ylabel('Beamforming Gain (dB)');
title('Beamforming Gain vs. Number of UEs');
grid on;

% Plot 4: SINR vs. Number of UEs (for different antenna configurations)
subplot(3, 3, 4);
SINR_values = zeros(length(K_values), length(M_values));
for i = 1:length(M_values)
    M = M_values(i);
    for j = 1:length(K_values)
        K = K_values(j);
        SINR_values(j, i) = mean(results.(sprintf('M%d_K%d', M, K)).SINR_ZF);
    end
end
plot(K_values, SINR_values, '-o');
xlabel('Number of UEs');
ylabel('Average SINR (dB)');
title('SINR vs. Number of UEs');
legend(arrayfun(@(M) sprintf('M=%d', M), M_values, 'UniformOutput', false));
grid on;

% Plot 5: Capacity Distribution
subplot(3, 3, 5);
capacity_values = results.(sprintf('M128_K10', 10)).Capacity_ZF; % Example for K=10 and M=128
histogram(capacity_values, 20); % Histogram with 20 bins
xlabel('Capacity (Gbps)');
ylabel('Frequency');
title('Capacity Distribution for M=128');
grid on;

% Plot 6: Spectral Efficiency vs. Number of UEs
subplot(3, 3, 6);
spectral_efficiency = zeros(length(K_values), 1);
for i = 1:length(K_values)
    K = K_values(i);
    spectral_efficiency(i) = sum(results.(sprintf('M128_K%d', K)).Capacity_ZF) / (BW * K); % Spectral efficiency
end
plot(K_values, spectral_efficiency, '-o');
xlabel('Number of UEs');
ylabel('Spectral Efficiency (bps/Hz per antenna)');
title('Spectral Efficiency vs. Number of UEs');
grid on;

% Plot 7: SINR vs. BS Antennas (for different UEs configurations)
subplot(3, 3, 7);
SINR_BS_antennas = zeros(length(M_values), 1);
for i = 1:length(M_values)
    M = M_values(i);
    SINR_BS_antennas(i) = mean(results.(sprintf('M%d_K100', M)).SINR_ZF); % Example for K=100
end
plot(M_values, SINR_BS_antennas, '-o');
xlabel('Number of BS Antennas');
ylabel('Average SINR (dB)');
title('SINR vs. BS Antennas');
grid on;

% Plot 8: Energy Efficiency vs. Number of Antennas
subplot(3, 3, 8);
energy_efficiency = zeros(length(M_values), 1);
for i = 1:length(M_values)
    M = M_values(i);
    energy_efficiency(i) = Ptx / results.(sprintf('M%d_K10', M)).SumRate_ZF; % Energy efficiency (W/Gbps)
end
plot(M_values, energy_efficiency, '-o');
xlabel('Number of Antennas');
ylabel('Energy Efficiency (W/Gbps)');
title('Energy Efficiency vs. Number of Antennas');
grid on;

% Plot 9: Cell Coverage vs. Performance
subplot(3, 3, 9);
radius_values = [500, 1000, 1500]; % Different cell radii
coverage_performance = zeros(length(radius_values), 1);
for i = 1:length(radius_values)
    r = radius_values(i);
    % Recalculate coverage/performance metrics based on radius
    coverage_performance(i) = sum(results.(sprintf('M128_K10', 10)).SumRate_ZF); % Example for SumRate
end
plot(radius_values, coverage_performance, '-o');
xlabel('Cell Radius (m)');
ylabel('Sum-Rate (Gbps)');
title('Cell Coverage vs. Performance');
grid on;

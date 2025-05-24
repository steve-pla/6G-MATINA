% MATLAB Script for Digital Beamforming to Mitigate Interference

clear; clc; close all;

%% Parameters
num_BS = 2;          % Number of Base Stations
num_UE_per_BS = 2;   % Users per Base Station
num_antennas = 4;    % Antennas per BS (MIMO setup)
noise_power = 1e-9;  % Noise power (W)
P_tx = 20;            % Transmit power per BS (W)
distance_BS = 1000;  % Distance between BSs (meters)
BW_Hz = 20e6;        % Bandwidth in Hz

%% Fixed BS and User Positions
BS_positions = [0, 0;  % BS1 at origin (0,0)
                1000, 0]; % BS2 at (1000,0), 1 km apart

user_positions = [50, 50;  % User 1 at (50, 50) meters from BS1
                  150, 50;  % User 2 at (150, 50) meters from BS1
                  50, 150;  % User 3 at (50, 150) meters from BS2
                  150, 150]; % User 4 at (150, 150) meters from BS2
%% Generate Channel Matrices
H = cell(num_BS, num_UE_per_BS);
for bs = 1:num_BS
    for ue = 1:num_UE_per_BS
        % Calculate channel based on user positions (this could be adjusted further for specific models)
        dist = norm(BS_positions(bs, :) - user_positions(ue, :));  % Euclidean distance
        H{bs, ue} = (randn(num_antennas, 1) + 1j*randn(num_antennas, 1)) / sqrt(2);  % Rayleigh Fading
    end
end

%% Compute Beamforming Weights (Zero-Forcing & MMSE)
W_ZF = cell(num_BS, 1);
W_MMSE = cell(num_BS, 1);
regularization = 0.01; % Regularization for MMSE

for bs = 1:num_BS
    H_BS = [H{bs,1}, H{bs,2}];  % Channel matrix for all UEs at BS
    W_ZF{bs} = H_BS' * inv(H_BS * H_BS');  % Zero-Forcing Precoding
    W_MMSE{bs} = H_BS' * inv(H_BS * H_BS' + regularization * eye(size(H_BS, 1)));  % MMSE Precoding
end

%% Compute SINR and Achievable Rate
SINR_ZF = zeros(num_BS, num_UE_per_BS);
SINR_MMSE = zeros(num_BS, num_UE_per_BS);
SINR_NoBF = zeros(num_BS, num_UE_per_BS);
rate_ZF = zeros(num_BS, num_UE_per_BS);
rate_MMSE = zeros(num_BS, num_UE_per_BS);
rate_NoBF = zeros(num_BS, num_UE_per_BS);
capacity_ZF = zeros(num_BS, num_UE_per_BS);
capacity_MMSE = zeros(num_BS, num_UE_per_BS);
capacity_NoBF = zeros(num_BS, num_UE_per_BS);

for bs = 1:num_BS
    for ue = 1:num_UE_per_BS
        % Desired Signal Power
        signal_power_ZF = abs(H{bs,ue}' * W_ZF{bs}(:,ue))^2 * P_tx;
        signal_power_MMSE = abs(H{bs,ue}' * W_MMSE{bs}(:,ue))^2 * P_tx;
        signal_power_NoBF = abs(H{bs,ue}' * ones(num_antennas,1)/sqrt(num_antennas))^2 * P_tx;
        
        % Interference Power from other BS
        interference_ZF = 0;
        interference_MMSE = 0;
        interference_NoBF = 0;
        for bs_interf = 1:num_BS
            if bs_interf ~= bs % Interference from the other BS
                interference_ZF = interference_ZF + abs(H{bs_interf,ue}' * W_ZF{bs_interf}(:,ue))^2 * P_tx;
                interference_MMSE = interference_MMSE + abs(H{bs_interf,ue}' * W_MMSE{bs_interf}(:,ue))^2 * P_tx;
                interference_NoBF = interference_NoBF + abs(H{bs_interf,ue}' * ones(num_antennas,1)/sqrt(num_antennas))^2 * P_tx;
            end
        end
        
        % Compute SINR
        SINR_ZF(bs, ue) = signal_power_ZF / (interference_ZF + noise_power);
        SINR_MMSE(bs, ue) = signal_power_MMSE / (interference_MMSE + noise_power);
        SINR_NoBF(bs, ue) = signal_power_NoBF / (interference_NoBF + noise_power);
        
        % Compute Achievable Rate (bps/Hz) and Capacity (Mbps)
        rate_ZF(bs, ue) = log2(1 + SINR_ZF(bs, ue));
        rate_MMSE(bs, ue) = log2(1 + SINR_MMSE(bs, ue));
        rate_NoBF(bs, ue) = log2(1 + SINR_NoBF(bs, ue));
        capacity_ZF(bs, ue) = BW_Hz * rate_ZF(bs, ue) / 1e6; % Convert to Mbps
        capacity_MMSE(bs, ue) = BW_Hz * rate_MMSE(bs, ue) / 1e6; % Convert to Mbps
        capacity_NoBF(bs, ue) = BW_Hz * rate_NoBF(bs, ue) / 1e6; % Convert to Mbps
    end
end

%% Display Results
fprintf('\n=== SINR and Achievable Rates ===\n');
for bs = 1:num_BS
    for ue = 1:num_UE_per_BS
        fprintf('BS %d - UE %d: SINR ZF = %.2f dB, Rate ZF = %.2f bps/Hz, Capacity ZF = %.2f Mbps\n', bs, ue, 10*log10(SINR_ZF(bs, ue)), rate_ZF(bs, ue), capacity_ZF(bs, ue));
        fprintf('BS %d - UE %d: SINR MMSE = %.2f dB, Rate MMSE = %.2f bps/Hz, Capacity MMSE = %.2f Mbps\n', bs, ue, 10*log10(SINR_MMSE(bs, ue)), rate_MMSE(bs, ue), capacity_MMSE(bs, ue));
        fprintf('BS %d - UE %d: SINR No BF = %.2f dB, Rate No BF = %.2f bps/Hz, Capacity No BF = %.2f Mbps\n', bs, ue, 10*log10(SINR_NoBF(bs, ue)), rate_NoBF(bs, ue), capacity_NoBF(bs, ue));
    end
end

%% Plot Capacity as Bar Plot
figure;
x_labels = {'BS1-UE1', 'BS1-UE2', 'BS2-UE1', 'BS2-UE2'};
bar_data = [capacity_ZF(:), capacity_MMSE(:), capacity_NoBF(:)];
bar(bar_data);
legend('Zero-Forcing BF', 'MMSE BF', 'No BF');
title('Capacity Comparison (Mbps)');
ylabel('Capacity (Mbps)');
set(gca, 'xticklabel', x_labels);
grid on;

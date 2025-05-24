% Parameters
fc = 2e9; % Carrier frequency (2 GHz)
B = 10e6; % Bandwidth (10 MHz)
P_tx = 20; % Transmit power (20 W)
P_noise = 1e-12; % Noise power (1 pW)
c = 3e8; % Speed of light
N_antennas = 64; % Number of antennas per BS (now 64)

% Base station locations
BS1 = [0, 0];
BS2 = [1500, 0];

% Generate random user locations
rng(42); % Set seed for reproducibility
users_BS1 = -2000 + 4000 * rand(10, 2); % Cluster 1: 10 users within 2 km of BS1
users_BS2 = [1500, 0] + (-2000 + 4000 * rand(10, 2)); % Cluster 2: 10 users within 2 km of BS2

% Initialize arrays to store capacities
capacities_no_BF_BS1 = zeros(10, 1); % Capacities without beamforming (BS1 users)
capacities_no_BF_BS2 = zeros(10, 1); % Capacities without beamforming (BS2 users)
capacities_ZF_BF_BS1 = zeros(10, 1); % Capacities with ZF beamforming (BS1 users)
capacities_ZF_BF_BS2 = zeros(10, 1); % Capacities with ZF beamforming (BS2 users)

% Function to calculate path loss
PL = @(d) 20 * log10(d) + 20 * log10(fc) + 20 * log10((4 * pi) / c);

% Calculate channel vectors for all users
H_BS1 = zeros(10, N_antennas); % Channel vectors for BS1 users (10x64)
H_BS2 = zeros(10, N_antennas); % Channel vectors for BS2 users (10x64)

for i = 1:10
    % Distance to BS1 and BS2
    d1 = norm(users_BS1(i, :) - BS1);
    d2 = norm(users_BS1(i, :) - BS2);
    
    % Path loss and channel gain
    PL1 = PL(d1);
    PL2 = PL(d2);
    h1 = 10^(-PL1 / 10);
    h2 = 10^(-PL2 / 10);
    
    % Channel vectors (Rayleigh fading)
    H_BS1(i, :) = sqrt(h1) * (randn(1, N_antennas) + 1i * randn(1, N_antennas)) / sqrt(2);
    H_BS2(i, :) = sqrt(h2) * (randn(1, N_antennas) + 1i * randn(1, N_antennas)) / sqrt(2);
end

% Calculate capacities without beamforming
for i = 1:10
    % For BS1 users
    d1 = norm(users_BS1(i, :) - BS1);
    d2 = norm(users_BS1(i, :) - BS2);
    PL1 = PL(d1);
    PL2 = PL(d2);
    h1 = 10^(-PL1 / 10);
    h2 = 10^(-PL2 / 10);
    
    % Received power and interference
    P_rx_BS1 = P_tx * h1;
    P_int_BS1 = P_tx * h2;
    
    % SINR and capacity
    SINR_BS1 = P_rx_BS1 / (P_int_BS1 + P_noise);
    capacities_no_BF_BS1(i) = B * log2(1 + SINR_BS1) / 1e6; % Capacity in Mbps
    
    % For BS2 users
    d1 = norm(users_BS2(i, :) - BS2);
    d2 = norm(users_BS2(i, :) - BS1);
    PL1 = PL(d1);
    PL2 = PL(d2);
    h1 = 10^(-PL1 / 10);
    h2 = 10^(-PL2 / 10);
    
    % Received power and interference
    P_rx_BS2 = P_tx * h1;
    P_int_BS2 = P_tx * h2;
    
    % SINR and capacity
    SINR_BS2 = P_rx_BS2 / (P_int_BS2 + P_noise);
    capacities_no_BF_BS2(i) = B * log2(1 + SINR_BS2) / 1e6; % Capacity in Mbps
end

% ZF Beamforming for BS1 and BS2
W_BS1 = pinv(H_BS1); % ZF weights for BS1 (64x10 matrix)
W_BS2 = pinv(H_BS2); % ZF weights for BS2 (64x10 matrix)

% Normalize beamforming vectors to meet power constraints
W_BS1 = W_BS1 ./ vecnorm(W_BS1, 2, 1); % Normalize columns (64x10)
W_BS2 = W_BS2 ./ vecnorm(W_BS2, 2, 1); % Normalize columns (64x10)

% Calculate capacities with ZF beamforming
for i = 1:10
    % For BS1 users
    desired_power_BS1 = abs(H_BS1(i, :) * W_BS1(:, i))^2 * P_tx;
    interference_power_BS1 = sum(abs(H_BS2(i, :) * W_BS2).^2) * P_tx; % Interference from BS2
    SINR_ZF_BS1 = desired_power_BS1 / (interference_power_BS1 + P_noise);
    capacities_ZF_BF_BS1(i) = B * log2(1 + SINR_ZF_BS1) / 1e6; % Capacity in Mbps
    
    % For BS2 users
    desired_power_BS2 = abs(H_BS2(i, :) * W_BS2(:, i))^2 * P_tx;
    interference_power_BS2 = sum(abs(H_BS1(i, :) * W_BS1).^2) * P_tx; % Interference from BS1
    SINR_ZF_BS2 = desired_power_BS2 / (interference_power_BS2 + P_noise);
    capacities_ZF_BF_BS2(i) = B * log2(1 + SINR_ZF_BS2) / 1e6; % Capacity in Mbps
end

% Combine capacities
all_capacities_no_BF = [capacities_no_BF_BS1; capacities_no_BF_BS2];
all_capacities_ZF_BF = [capacities_ZF_BF_BS1; capacities_ZF_BF_BS2];

% Plot
figure;
bar(1:20, [all_capacities_no_BF, all_capacities_ZF_BF]);
xlabel('User Index');
ylabel('Capacity (Mbps)');
title('Downlink Capacities: No BF vs ZF BF (64 Antennas)');
legend('No Beamforming', 'ZF Beamforming');
grid on;
% Simulation parameters
N_antennas = 100; % Number of antennas per TBS (Massive MIMO)
K_users = 10;      % Number of users per cluster
num_clusters = 2; % Number of clusters (TBSs)
Pt = 1;           % Transmit power (normalized)
N0 = 1e-9;        % Noise power
BW = 1e6;         % Bandwidth
num_realizations = 100; % Number of channel realizations

% Define TBS locations (example - STATIC)
TBS_locations = [0, 0; 1000, 1000]; % Example locations - THESE ARE NOW STATIC

% Initialize variables to store results
SINR_no_beamforming = zeros(num_realizations, K_users * num_clusters);
SINR_ZF = zeros(num_realizations, K_users * num_clusters);
SINR_MMSE = zeros(num_realizations, K_users * num_clusters);
Capacity_no_beamforming = zeros(num_realizations, K_users * num_clusters);
Capacity_ZF = zeros(num_realizations, K_users * num_clusters);
Capacity_MMSE = zeros(num_realizations, K_users * num_clusters);
Interference_no_beamforming = zeros(num_realizations, K_users * num_clusters);
Interference_ZF = zeros(num_realizations, K_users * num_clusters);
Interference_MMSE = zeros(num_realizations, K_users * num_clusters);

for real = 1:num_realizations % Loop over channel realizations
    % User locations (example - clustered around TBS - STATIC)
    user_locations = zeros(K_users * num_clusters, 2);
    for i = 1:num_clusters
        for k = 1:K_users
            angle = 2 * pi * rand(); % Random angle
            distance = randi([50, 200]); % Random distance (adjust range as needed)
            user_locations((i - 1) * K_users + k, :) = TBS_locations(i,:) + [distance * cos(angle), distance * sin(angle)];
        end
    end

    % Channel model (Rayleigh fading with distance-dependent path loss)
    H = cell(num_clusters, 1); % Cell array to store channel matrices
    for i = 1:num_clusters
        H{i} = zeros(K_users, N_antennas); % Initialize channel matrix for each cluster
        for k = 1:K_users
            user_index = (i - 1) * K_users + k;
            distance = norm(user_locations(user_index,:) - TBS_locations(i,:));
            path_loss = 120 + 10*log10(distance); % Example path loss model (adjust as needed)
            H{i}(k,:) = (randn(1, N_antennas) + 1i*randn(1, N_antennas)) / sqrt(2) * 10^(-path_loss/20);
        end
    end

    % 1. No Beamforming (Omnidirectional Transmission)
    W_no_beamforming = cell(num_clusters, 1);
    for i = 1:num_clusters
        W_no_beamforming{i} = ones(N_antennas, K_users) / sqrt(N_antennas); % Equal gain for all users
    end

    SINR_no_beamforming_temp = zeros(1, K_users * num_clusters);
    Interference_no_beamforming_temp = zeros(1, K_users * num_clusters);
    for i = 1:num_clusters
        for k = 1:K_users
            user_index = (i - 1) * K_users + k; % Global user index
            signal_power = Pt * abs(H{i}(k, :) * W_no_beamforming{i}(:, k))^2;

            % Interference from other TBSs (downlink only)
            interference_power = 0;
            for j = 1:num_clusters
                if j ~= i % Interference from other TBSs
                    interference_power = interference_power + Pt * abs(H{j}(k, :) * W_no_beamforming{j}(:, k))^2;
                end
            end
            noise_power = N0;
            SINR_no_beamforming_temp(user_index) = signal_power / (interference_power + noise_power);
            Interference_no_beamforming_temp(user_index) = interference_power;
        end
    end
    SINR_no_beamforming(real,:) = SINR_no_beamforming_temp;
    Interference_no_beamforming(real,:) = Interference_no_beamforming_temp;
    Capacity_no_beamforming(real,:) = BW * log2(1 + SINR_no_beamforming_temp);

    % 2. Zero-Forcing (ZF) Beamforming
    W_ZF = cell(num_clusters, 1);
    for i = 1:num_clusters
        H_cluster = H{i}; % Channel matrix for the current cluster
        W_ZF{i} = H_cluster' * pinv(H_cluster * H_cluster'); % Zero-forcing
        W_ZF{i} = sqrt(Pt) * W_ZF{i} ./ vecnorm(W_ZF{i}); % Power normalization
    end

    SINR_ZF_temp = zeros(1, K_users * num_clusters);
    Interference_ZF_temp = zeros(1, K_users * num_clusters);
    for i = 1:num_clusters
        for k = 1:K_users
            user_index = (i - 1) * K_users + k; % Global user index
            signal_power = Pt * abs(H{i}(k, :) * W_ZF{i}(:, k))^2;

            % Interference from other TBSs (downlink only)
            interference_power = 0;
            for j = 1:num_clusters
                if j ~= i % Interference from other TBSs
                    interference_power = interference_power + Pt * abs(H{j}(k, :) * W_ZF{j}(:, k))^2;
                end
            end
            noise_power = N0;
            SINR_ZF_temp(user_index) = signal_power / (interference_power + noise_power);
            Interference_ZF_temp(user_index) = interference_power;
        end
    end
    SINR_ZF(real,:) = SINR_ZF_temp;
    Interference_ZF(real,:) = Interference_ZF_temp;
    Capacity_ZF(real,:) = BW * log2(1 + SINR_ZF_temp);

    % 3. MMSE Beamforming
    W_MMSE = cell(num_clusters, 1);
    for i = 1:num_clusters
        H_cluster = H{i}; % Channel matrix for the current cluster
        W_MMSE{i} = (H_cluster' * H_cluster + (N0 / Pt) * eye(N_antennas)) \ H_cluster';
    end

    SINR_MMSE_temp = zeros(1, K_users * num_clusters);
    Interference_MMSE_temp = zeros(1, K_users * num_clusters);
    for i = 1:num_clusters
        for k = 1:K_users
            user_index = (i - 1) * K_users + k; % Global user index
            signal_power = Pt * abs(H{i}(k, :) * W_MMSE{i}(:, k))^2;

            % Interference from other TBSs (downlink only)
            interference_power = 0;
            for j = 1:num_clusters
                if j ~= i % Interference from other TBSs
                    interference_power = interference_power + Pt * abs(H{j}(k, :) * W_MMSE{j}(:, k))^2;
                end
            end
            noise_power = N0;
            SINR_MMSE_temp(user_index) = signal_power / (interference_power + noise_power);
            Interference_MMSE_temp(user_index) = interference_power;
        end
    end
    SINR_MMSE(real,:) = SINR_MMSE_temp;
    Interference_MMSE(real,:) = Interference_MMSE_temp;
    Capacity_MMSE(real,:) = BW * log2(1 + SINR_MMSE_temp);
end

% Average SINR, Interference, and Capacity over all realizations
avg_SINR_no_beamforming_dB = 10 * log10(mean(SINR_no_beamforming, 1));
avg_SINR_ZF_dB = 10 * log10(mean(SINR_ZF, 1));
avg_SINR_MMSE_dB = 10 * log10(mean(SINR_MMSE, 1));

avg_Interference_no_beamforming = mean(Interference_no_beamforming, 1);
avg_Interference_ZF = mean(Interference_ZF, 1);
avg_Interference_MMSE = mean(Interference_MMSE, 1);

avg_Capacity_no_beamforming = mean(Capacity_no_beamforming, 1);
avg_Capacity_ZF = mean(Capacity_ZF, 1);
avg_Capacity_MMSE = mean(Capacity_MMSE, 1);

% User indices for bar charts
user_indices = 1:(K_users * num_clusters);

% Plotting SINR
figure;
bar(user_indices, [avg_SINR_no_beamforming_dB; avg_SINR_ZF_dB; avg_SINR_MMSE_dB]');
xlabel('User Index');
ylabel('SINR (dB)');
title('Average SINR per User');
legend('No Beamforming', 'ZF Beamforming', 'MMSE Beamforming');
grid on;

% Plotting Interference Power
figure;
bar(user_indices, [avg_Interference_no_beamforming; avg_Interference_ZF; avg_Interference_MMSE]');
xlabel('User Index');
ylabel('Interference Power');
title('Average Interference Power per User');
legend('No Beamforming', 'ZF Beamforming', 'MMSE Beamforming');
grid on;

% Plotting Capacity
figure;
bar(user_indices, [avg_Capacity_no_beamforming; avg_Capacity_ZF; avg_Capacity_MMSE]');
xlabel('User Index');
ylabel('Capacity (bps)');
title('Average Capacity per User');
legend('No Beamforming', 'ZF Beamforming', 'MMSE Beamforming');
grid on;
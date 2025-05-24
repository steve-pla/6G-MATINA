clc; clear; close all;

%% Parameters
num_BS = 3;
num_UEs = 9;
system_BW = 60e6; % 60 MHz total bandwidth
fc = 2.5e9; % Carrier frequency 2.5 GHz
c = 3e8;
lambda = c / fc;
noise_figure_dB = 7;
thermal_noise_dBm = -174 + 10*log10(system_BW);
noise_power_dBm = thermal_noise_dBm + noise_figure_dB;
noise_power = 10^((noise_power_dBm - 30)/10); % in Watts

%% Fixed BS positions
BS_positions = [0 0; 500 0; 250 433]; % Equilateral triangle

% Assign 3 UEs per BS, fixed
UE_positions = [100 0; 50 50; 150 -50; ...
                600 0; 550 50; 650 -50; ...
                250 500; 200 470; 300 470];

%% Path loss model (free space)
path_loss = @(d) (lambda ./ (4 * pi * d)).^2;

%% Baseline: Full Spectrum Reuse (same BW per UE, max interference)
BW_per_UE = system_BW / num_UEs;
capacity_baseline = zeros(1, num_UEs);

for i = 1:num_UEs
    bs_id = ceil(i / 3);
    d_serving = norm(UE_positions(i,:) - BS_positions(bs_id,:));
    h_serving = sqrt(path_loss(d_serving));

    interf_power = 0;
    for j = 1:num_BS
        if j ~= bs_id
            d_intf = norm(UE_positions(i,:) - BS_positions(j,:));
            h_intf = sqrt(path_loss(d_intf));
            interf_power = interf_power + h_intf^2;
        end
    end

    sinr = h_serving^2 / (interf_power + noise_power);
    capacity_baseline(i) = BW_per_UE * log2(1 + sinr) / 1e6; % in Mbps
end

avg_baseline = mean(capacity_baseline);

%% GA-based Spectrum Allocation Scheme (SAS)
pop_size = 50;
num_generations = 100;
mutation_rate = 0.1;
crossover_rate = 0.8;

% Objective function
objective_function = @(allocation) -sum(compute_capacities(allocation));

% GA options
options = optimoptions('ga', ...
    'PopulationSize', pop_size, ...
    'MaxGenerations', num_generations, ...
    'CrossoverFraction', crossover_rate, ...
    'MutationFcn', {@mutationuniform, mutation_rate}, ...
    'SelectionFcn', @selectionroulette, ...
    'CrossoverFcn', @crossoverscattered, ...
    'EliteCount', 2, ...
    'Display', 'off');

IntCon = 1:num_UEs;

[best_allocation, ~] = ga(objective_function, num_UEs, [], [], [], [], ...
    ones(1,num_UEs), num_BS * ones(1,num_UEs), [], IntCon, options);

%% Compute capacities for best GA allocation
capacity_sas = compute_capacities(best_allocation);
avg_sas = mean(capacity_sas);

%% Plot Results
figure;
bar([avg_baseline avg_sas])
set(gca, 'XTickLabel', {'Baseline (Reuse 1)', 'GA-SAS'}, 'FontSize', 12)
ylabel('Average DL Capacity [Mbps]')
title('Comparison of Average Downlink Capacity')
grid on;

figure;
plot(1:num_UEs, capacity_baseline, 'r-o', 'LineWidth', 1.5); hold on;
plot(1:num_UEs, capacity_sas, 'b-s', 'LineWidth', 1.5);
legend('Baseline', 'GA-SAS', 'Location', 'best');
xlabel('UE Index');
ylabel('Downlink Capacity [Mbps]');
title('Per-UE Downlink Capacity Comparison');
grid on;

%% Helper Function: Compute capacity for an allocation
function capacities = compute_capacities(allocation)
    num_BS = 3;
    system_BW = 60e6;
    fc = 2.5e9;
    c = 3e8;
    lambda = c / fc;
    noise_figure_dB = 7;
    thermal_noise_dBm = -174 + 10*log10(system_BW);
    noise_power_dBm = thermal_noise_dBm + noise_figure_dB;
    noise_power = 10^((noise_power_dBm - 30)/10); % in Watts

    BS_positions = [0 0; 500 0; 250 433];
    UE_positions = [100 0; 50 50; 150 -50; ...
                    600 0; 550 50; 650 -50; ...
                    250 500; 200 470; 300 470];

    path_loss = @(d) (lambda ./ (4 * pi * d)).^2;

    num_UEs = length(allocation);
    capacities = zeros(1, num_UEs);

    % Count how many UEs share each BS's assigned band
    UE_per_BS_band = zeros(num_BS, num_BS);
    for i = 1:num_UEs
        serving_bs = ceil(i/3); % fixed serving BS
        assigned_band = allocation(i);
        UE_per_BS_band(serving_bs, assigned_band) = ...
            UE_per_BS_band(serving_bs, assigned_band) + 1;
    end

    for i = 1:num_UEs
        serving_bs = ceil(i / 3);
        assigned_band = allocation(i);

        % Serving channel gain
        d_serving = norm(UE_positions(i,:) - BS_positions(serving_bs,:));
        h_serving = sqrt(path_loss(d_serving));

        % Interference from other BSs using same band
        interf_power = 0;
        for j = 1:num_BS
            if j ~= serving_bs && any(allocation(3*(j-1)+1:3*j) == assigned_band)
                d_intf = norm(UE_positions(i,:) - BS_positions(j,:));
                h_intf = sqrt(path_loss(d_intf));
                interf_power = interf_power + h_intf^2;
            end
        end

        % Bandwidth per UE on same BS and band
        sharing_UEs = UE_per_BS_band(serving_bs, assigned_band);
        BW_per_UE = system_BW / num_BS / sharing_UEs;

        sinr = h_serving^2 / (interf_power + noise_power);
        capacities(i) = BW_per_UE * log2(1 + sinr) / 1e6; % in Mbps
    end
end

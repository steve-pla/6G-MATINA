% -------------------------------------------------------------------------
% 6G-MATINA Simulator
% 6G-Maritime Aerial Terrestrial Intelligent Network Access Simulator
%
% Developed by: Stefanos Plastras
% Email: <s.plastras@aegean.gr>
% Contributors: Assistant Professor, Dr. Dimitrios N. Skoutas
% Email: <d.skoutas@aegean.gr>
% Computer & Communication Systems Lab
% University of the Aegean, Greece
% MATLAB-based Simulator
%
% This simulator investigates the deployment and performance of a 6G
% integrated network architecture for maritime environments. It incorporates
% Terrestrial Base Stations (TBS), Non-Terrestrial Networks (NTN) utilizing
% Unmanned Aerial Vehicles (UAVs), and Artificial Intelligence/Machine
% Learning (AI/ML) algorithms for intelligent UAV placement and network
% optimization.
% -------------------------------------------------------------------------
function [best_allocation, all_vessels_UEs_updated] = genetic_heuristic_spectrum_allocator_kmeans(...
    abs_relay_struct, all_vessels_UEs, ABS_placement_data, ABS_BW_Hz, No_Watt_Hz, ...
    vessel_associations, ABS_Pt_Watt, ABS_height_m, ABS_fc_Hz, N_abs, abs_cluster_vessels_limit)

% Number of UAVs / ABS (optimization variables)
num_UAVs = N_abs;

% Bounds for allocation variables (e.g., bandwidth fraction per UAV)
lb = zeros(num_UAVs,1);
ub = ones(num_UAVs,1);

% Objective function for GA (negative sum of capacities because ga minimizes)
objective_function = @(allocation) -sum(compute_capacities_with_constraints(...
    abs_relay_struct, all_vessels_UEs, allocation, ABS_BW_Hz, No_Watt_Hz, vessel_associations, ...
    ABS_Pt_Watt, ABS_placement_data, ABS_height_m, ABS_fc_Hz, N_abs, abs_cluster_vessels_limit));

% GA options - adjust as needed
options = optimoptions('ga','Display','iter','PopulationSize',50,'MaxGenerations',100);

% Run GA optimizer
[best_allocation, ~] = ga(objective_function, num_UAVs, [], [], [], [], lb, ub, [], options);

% Compute final capacities using best allocation
capacities = compute_capacities_with_constraints(...
    abs_relay_struct, all_vessels_UEs, best_allocation, ABS_BW_Hz, No_Watt_Hz, vessel_associations, ...
    ABS_Pt_Watt, ABS_placement_data, ABS_height_m, ABS_fc_Hz, N_abs, abs_cluster_vessels_limit);

% Assign capacities to each vessel struct element properly
for i = 1:length(all_vessels_UEs)
    all_vessels_UEs(i).updated_capacity_Mbps = capacities(i);
end

all_vessels_UEs_updated = all_vessels_UEs;

end

%%
function capacities = compute_capacities_with_constraints(abs_relay_struct, all_vessels_UEs, allocation, ABS_BW_Hz, No_Watt_Hz, vessel_associations, ABS_Pt_Watt, ABS_placement_data, ABS_height_m, ABS_fc_Hz, N_abs, abs_cluster_vessels_limit)

vessel_associations = vessel_associations(:); % ensure column vector
assigned_vessels = vessel_associations(vessel_associations > 0);

% Count vessels assigned per ABS (only positive indices allowed)
vessel_counts = accumarray(assigned_vessels, 1, [N_abs, 1]);

num_vessels = length(vessel_associations);
capacities = zeros(num_vessels, 1);

for v = 1:num_vessels
    serving_abs = vessel_associations(v);

    if serving_abs == 0
        % Vessel not served by any ABS → zero capacity
        capacities(v) = 0;
        continue;
    end

    % Check vessel limit per ABS cluster
    if vessel_counts(serving_abs) > abs_cluster_vessels_limit
        % Penalize exceeding vessel limit by zero capacity
        capacities(v) = 0;
        continue;
    end

    % Calculate capacity for vessel v served by ABS serving_abs
    capacities(v) = compute_capacity_for_vessel(v, serving_abs, allocation, abs_relay_struct, all_vessels_UEs, ABS_BW_Hz, No_Watt_Hz, ABS_Pt_Watt, ABS_placement_data, ABS_height_m, ABS_fc_Hz);
end

end

%%
function cap = compute_capacity_for_vessel(vessel_idx, serving_abs, allocation, abs_relay_struct, all_vessels_UEs, ABS_BW_Hz, No_Watt_Hz, ABS_Pt_Watt, ABS_placement_data, ABS_height_m, ABS_fc_Hz)
% Placeholder capacity computation: replace with your actual model
% Bandwidth allocated to the serving ABS
BW_allocated = allocation(serving_abs) * ABS_BW_Hz;
noise_power = No_Watt_Hz * BW_allocated;
% Example path gain (replace with your actual channel gain)
channel_gain = 1e-6;

received_power = ABS_Pt_Watt * channel_gain;

SNR = received_power / noise_power;

% Shannon capacity (bps)
cap = BW_allocated * log2(1 + SNR);
% Convert to Mbps
cap = cap / 1e6;

end

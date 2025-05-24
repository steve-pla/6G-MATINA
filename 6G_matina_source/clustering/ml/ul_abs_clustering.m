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
function [ABS_placement_data, vessel_associations] = ul_abs_clustering(method, total_vessel_ue_in_out_hotspots, uav_N, abs_height_m, abs_cluster_vessels_limit_N)
    % Function to place ABSs via clustering with a per-ABS vessel association limit.
    % Unassigned vessels (due to UAV limit) are marked with index 0.
    %
    % Inputs:
    %   method            - Clustering method ('kmeans', 'kmedoids', 'fuzzy')
    %   all_vessels_UEs   - Struct with vessel data (x,y)
    %   N_abs             - Number of ABSs
    %   abs_height        - ABS altitude
    %   abs_cluster_limit - Maximum number of vessels per ABS
    %
    % Outputs:
    %   ABS_placement_data - Struct array with ABS positions
    %   vessel_associations - Vector assigning each vessel to an ABS index, or 0 if unassigned

    TableUE = struct2table(total_vessel_ue_in_out_hotspots);
    data = table2array(TableUE(:, 1:2));  % Vessel coordinates
    num_vessels = size(data, 1);

    % --- Step 1: Clustering ---
    switch lower(method)
        case 'kmeans'
            [idx, C] = kmeans(data, uav_N);
        case 'kmedoids'
            [idx, C] = kmedoids(data, uav_N);
        case 'fuzzy'
            [centers, U] = fcm(data, uav_N);
            [~, idx] = max(U, [], 1);
            idx = idx';
            C = centers;
        otherwise
            error('Unknown clustering method: %s', method);
    end

    % --- Step 2: Vessel assignment with limit ---
    vessel_associations = zeros(num_vessels, 1);  % Default: unassigned (0)
    abs_counts = zeros(uav_N, 1);                 % Count vessels per ABS

    for i = 1:num_vessels
        preferred_abs = idx(i);
        if abs_counts(preferred_abs) < abs_cluster_vessels_limit_N
            vessel_associations(i) = preferred_abs;
            abs_counts(preferred_abs) = abs_counts(preferred_abs) + 1;
        else
            % Try assigning to a nearby ABS that has capacity
            dists = vecnorm(C - data(i, :), 2, 2);
            [~, sorted_abs] = sort(dists);
            assigned = false;
            for j = 1:uav_N
                candidate = sorted_abs(j);
                if abs_counts(candidate) < abs_cluster_vessels_limit_N
                    vessel_associations(i) = candidate;
                    abs_counts(candidate) = abs_counts(candidate) + 1;
                    assigned = true;
                    break;
                end
            end
            % If no ABS has capacity, vessel remains unassigned (0)
        end
    end

    % --- Step 3: Output ABS placement ---
    ABS_placement_data = struct([]);
    for i = 1:uav_N
        ABS_placement_data(i).x = C(i, 1);
        ABS_placement_data(i).y = C(i, 2);
        ABS_placement_data(i).z = abs_height_m;
        ABS_placement_data(i).index = i;
    end
end

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
% This file will call all the other auxiliary files.
% First, start measuring execution time.
% --------------------------------------
tic;
% Log the start of the MATALB Simulator
% --------------------------------------
% Unique ID Simulation Execution
execID = datestr(now, 'yyyymmdd_HHMMSS');
logger("Starting 6G-MATINA Simulator -> " + execID);
% Read 'configuration.m' file
% ---------------------------------------------------------------
try
    conf_file_name = "configuration.m";
    run(conf_file_name);  % Attempt to run the configuration file
catch ME
    logger('Error loading configuration file -> ' + conf_file_name);
    % You could also provide default values or exit the script gracefully here
    % exit; % Terminate the entire MATLAB session
end




% Run basic scenario where we calculate Vessels rate from only TBS, then
% deploy ABSs with 3 MLs, calculate downlink ABSs rate Full Interference
% f.i., and then apply spectrum allocation s.a., using genetic algorithm.
% --------------------------------------------------------------------------------------
[dl_vessels_rate_with_no_uav_list, dl_vessels_rate_with_ml_uav_kmeans_fi_list,...
    dl_vessels_rate_with_ml_uav_kmedoids_fi_list, dl_vessels_rate_with_ml_uav_fcm_fi_list,...
    dl_vessels_rate_with_ml_uav_kmeans_sa_list, dl_vessels_rate_with_ml_uav_kmedoids_sa_list,...
    dl_vessels_rate_with_ml_uav_fcm_sa_list, dl_uavs_rate_with_ml_uav_kmeans_list,...
    dl_uavs_rate_with_ml_uav_kmedoids_list, dl_uavs_rate_with_ml_uav_fcm_list] = scenario_with_ml_uav_fi_sa_runner(...
    monte_carlo_iterations_N_conf, area_min_m_conf, area_max_m_conf, total_vessels_N_conf, uav_N_conf,...
    abs_height_m_conf, abs_fc_Hz_conf, abs_BW_Hz_conf, abs_Pt_Watt_conf, abs_cluster_vessels_limit_N_conf, vessel_hotspots_N_conf, lambda_N_vessels_conf, ...
    vessel_hotspots_radius_m_conf, tbs_1_BW_Hz_conf, tbs_1_Fc_Hz_conf, tbs_1_Pt_dBm_conf, ...
    tbs_2_BW_Hz_conf, tbs_2_Fc_Hz_conf, tbs_2_Pt_dBm_conf, tbs_3_BW_Hz_conf, tbs_3_Fc_Hz_conf,...
    tbs_3_Pt_dBm_conf, tbs_1_Pt_Watt_conf, tbs_2_Pt_Watt_conf, tbs_3_Pt_Watt_conf, tbs_height_m_conf,...
    noise_Watt_Hz_conf, maritime_loss_dB_conf, sea_attenuation_dB_conf, vessel_antenna_height_m_conf,...
    reference_distance_tbs_vessel_m_conf);
% Now, we have the lists with all dl rates in all cases. 
% Let's plot them.
% -------------------------------------------------------------------------



% Call topology ploter to see the network!!!
% For testing purposes ONLY
% ------------------------------------------
scenario_with_ml_uav_fi_tester.m;


%{

% ---------------------------------------------------------------
% Call, the runners for the scenarios and apply Monte Carlo
% Power range
abs_power_ranges = [0.001, 0.01, 0.1, 1, 4, 10]; % ABSs Power ranges (Watts)
num_abs_power_ranges = length(abs_power_ranges);
% ABSs range
NoABS_values = [1, 2, 5, 9, 10, 12, 20];
% BW range
BW_range = [5e6, 10e6, 15e6, 20e6, 40e6, 60e6, 100e6];  % in Hz
% -------------------------------------------------------------
% Store capacity results
% -----------------6 schemes for Vessels---------------------------------------------------------------------
vessels_capacity_from_tbs_basic_scenario_no_abs = zeros(Monte_carlo_N_iterations, N_vessels);
vessels_capacity_from_abs_random_no_sap_from_tbs_scenario_abs = zeros(Monte_carlo_N_iterations, num_abs_power_ranges, N_vessels);
% Random & Grid-based Placement with and with no Spectrum Allocation
vessels_capacity_from_abs_grid_no_sap_from_tbs_scenario_abs = zeros(Monte_carlo_N_iterations, num_abs_power_ranges, N_vessels);
vessels_capacity_from_abs_random_GA_sap_from_tbs_scenario_abs = zeros(Monte_carlo_N_iterations, num_abs_power_ranges, N_vessels);
vessels_capacity_from_abs_grid_GA_sap_from_tbs_scenario_abs = zeros(Monte_carlo_N_iterations, num_abs_power_ranges, N_vessels);
% 3 ML placements with and with no Spectrum Allocation
vessels_capacity_from_abs_kmeans_no_sap_from_tbs_scenario_ml = zeros(Monte_carlo_N_iterations, num_abs_power_ranges, N_vessels);
vessels_capacity_from_abs_kmedoids_no_sap_from_tbs_scenario_ml = zeros(Monte_carlo_N_iterations, num_abs_power_ranges, N_vessels);
vessels_capacity_from_abs_fuzzmeans_no_sap_from_tbs_scenario_ml = zeros(Monte_carlo_N_iterations, num_abs_power_ranges, N_vessels);
vessels_capacity_from_abs_kmeans_GA_sap_from_tbs_scenario_ml = zeros(Monte_carlo_N_iterations, num_abs_power_ranges, N_vessels);
vessels_capacity_from_abs_kmedoids_GA_sap_from_tbs_scenario_ml = zeros(Monte_carlo_N_iterations, num_abs_power_ranges, N_vessels);
vessels_capacity_from_abs_fuzzmeans_GA_sap_from_tbs_scenario_ml = zeros(Monte_carlo_N_iterations, num_abs_power_ranges, N_vessels);

for iter = 1:Monte_carlo_N_iterations

    [TBS1, TBS2, TBS3, all_vessels_UEs, vessel_hotspots, vessel_hotspots_UEs, outer_vessel_UEs, number_outer_vessel] = topology_initializer(Area_min_m, Area_max_m, N_vessels, N_vessel_hotspots, Lambda, ...
        Vessel_hotspots_radius_m, TBS_1_BW_Hz, TBS_1_Fc_Hz, TBS_1_Pt_dBm, TBS_2_BW_Hz, TBS_2_Fc_Hz, TBS_2_Pt_dBm, TBS_3_BW_Hz, TBS_3_Fc_Hz, TBS_3_Pt_dBm, TBS_height_m, TBS_1_Pt_Watt, TBS_2_Pt_Watt, TBS_3_Pt_Watt);

    % Convert UE to a numerical array of coordinates *before* the loop
    % all_vessels_UEs_coordinates = [all_vessels_UEs.x; all_vessels_UEs.y]';  % Efficient way to extract coordinates

    % ---------------------------------------------------------------
    % Call the 3 ML models to produce places for all the ABSs.
    [ABS_placement_data_Kmeans, vessel_associations_kmeans] = ul_abs_clustering('kmeans', all_vessels_UEs, N_abs, ABS_height_m);
    [ABS_placement_data_kmedoids, vessel_associations_kmedoids] = ul_abs_clustering('kmedoids', all_vessels_UEs, N_abs, ABS_height_m);
    [ABS_placement_data_fuzzymeans, vessel_associations_fuzzy_means] = ul_abs_clustering('fuzzy', all_vessels_UEs, N_abs, ABS_height_m);

    % Call basic scenario.
    % Basic Scenario here. Only Vessels served by 3 TBSs.
    % --------------------------------------------------
    all_vessels_UEs_v1 = basic_lscenario_runner_no_abs(all_vessels_UEs, N_vessels, TBS_height_m, TBS1, TBS2, TBS3, TBS_1_BW_Hz, TBS_2_BW_Hz, TBS_3_BW_Hz, No_Watt_Hz, Maritime_loss_dB, ...
        Sea_attenuation_dB, Vessel_antenna_height_m, Reference_distance_tbs_vessel_m);
    % Extract capacities from updated struct
    for vessel = 1:N_vessels
        vessels_capacity_from_tbs_basic_scenario_no_abs(iter, vessel) = all_vessels_UEs_v1(vessel).capacity_vessel_Mbps;
    end

    % Call 2 Clustering ABSs scenario. - Random & Grid Clusterings.
    % Clustering ABS Scenario here. Vessels now served by ABSs.
    % ------------------------------------------------------------
    % Power Range Inner Loop
    for power_iter = 1:num_abs_power_ranges
        varying_abs_power = abs_power_ranges(power_iter);
        [abs_relay_struct_v1, all_vessels_UEs_v2] = scenario_runner_with_baseline_clusterings_abs(ABS_placement_data_uniform, ABS_placement_data_grid, TBS1, TBS2, TBS3, ABS_height_m, TBS_1_BW_Hz, ...
            TBS_2_BW_Hz, TBS_3_BW_Hz, N_abs, No_Watt_Hz, vessel_associations_uniform, vessel_associations_grid, all_vessels_UEs, ABS_fc_Hz, ABS_Pt_Watt, ABS_BW_Hz, N_vessels, varying_abs_power);
        % Genetic Algorithm Spectrum Allocation Policy - GA-SAP.
        [~, all_vessels_UEs_GA_uniform_v2] = genetic_heuristic_spectrum_allocator_uniform(abs_relay_struct_v1, all_vessels_UEs_v2, ABS_placement_data_uniform, ABS_BW_Hz, No_Watt_Hz, vessel_associations_uniform, ...
            varying_abs_power, ABS_height_m, ABS_fc_Hz, N_abs);
        [~, all_vessels_UEs_GA_grid_v2] = genetic_heuristic_spectrum_allocator_grid(abs_relay_struct_v1, all_vessels_UEs_v2, ABS_placement_data_grid, ABS_BW_Hz, No_Watt_Hz, vessel_associations_grid, varying_abs_power, ...
            ABS_height_m, ABS_fc_Hz, N_abs);
        % Extract capacities from updated struct
        for vessel = 1:N_vessels
            vessels_capacity_from_abs_random_no_sap_from_tbs_scenario_abs(iter, power_iter, vessel) = all_vessels_UEs_v2(vessel).final_capacity_downlink_uniform_Mbps;
            vessels_capacity_from_abs_grid_no_sap_from_tbs_scenario_abs(iter, power_iter, vessel) = all_vessels_UEs_v2(vessel).final_capacity_downlink_grid_Mbps;
            vessels_capacity_from_abs_random_GA_sap_from_tbs_scenario_abs(iter, power_iter, vessel) = all_vessels_UEs_GA_uniform_v2(vessel);
            vessels_capacity_from_abs_grid_GA_sap_from_tbs_scenario_abs(iter, power_iter, vessel) = all_vessels_UEs_GA_grid_v2(vessel);
        end
    end

    % Call 3 ML ABSs scenario. KMEANS, KMEDOIDS AND FUZZY-MEANS.
    % 3 ML ABS Scenario here. Vessels now served by ABSs.
    % ---------------------------------------------------------
    % Power Range Inner Loop
    for power_iter = 1:num_abs_power_ranges
        varying_abs_power = abs_power_ranges(power_iter);
        [abs_relay_struct_v2, all_vessels_UEs_v3] = scenario_runner_with__ml_abs(ABS_placement_data_Kmeans, ABS_placement_data_kmedoids, ABS_placement_data_fuzzymeans, TBS1, TBS2, TBS3, ABS_height_m, TBS_1_BW_Hz, ...
            TBS_2_BW_Hz, TBS_3_BW_Hz, N_abs, No_Watt_Hz, vessel_associations_kmeans, vessel_associations_kmedoids, vessel_associations_fuzzy_means, all_vessels_UEs, ABS_fc_Hz, ABS_Pt_Watt, ABS_BW_Hz, N_vessels, varying_abs_power);
        % Genetic Algorithm Spectrum Allocation Policy - GA-SAP.
        [~, all_vessels_UEs_GA_kmeans_v3] = genetic_heuristic_spectrum_allocator_kmeans(abs_relay_struct_v2, all_vessels_UEs_v3, ABS_placement_data_Kmeans, ABS_BW_Hz, No_Watt_Hz, vessel_associations_kmeans, ...
            varying_abs_power, ABS_height_m, ABS_fc_Hz, N_abs);
        [~, all_vessels_UEs_GA_kmedoids_v3] = genetic_heuristic_spectrum_allocator_kmedoids(abs_relay_struct_v2, all_vessels_UEs_v3, ABS_placement_data_kmedoids, ABS_BW_Hz, No_Watt_Hz, vessel_associations_kmedoids, varying_abs_power, ...
            ABS_height_m, ABS_fc_Hz, N_abs);
        [~, all_vessels_UEs_GA_fuzzy_means_v3] = genetic_heuristic_spectrum_allocator_fuzzy_means(abs_relay_struct_v2, all_vessels_UEs_v3, ABS_placement_data_fuzzymeans, ABS_BW_Hz, No_Watt_Hz, vessel_associations_fuzzy_means, varying_abs_power, ...
            ABS_height_m, ABS_fc_Hz, N_abs);
        % Extract capacities from updated struct
        for vessel = 1:N_vessels
            vessels_capacity_from_abs_kmeans_no_sap_from_tbs_scenario_ml(iter, power_iter, vessel) = all_vessels_UEs_v3(vessel).final_capacity_downlink_kmeans_Mbps;
            vessels_capacity_from_abs_kmedoids_no_sap_from_tbs_scenario_ml(iter, power_iter, vessel) = all_vessels_UEs_v3(vessel).final_capacity_downlink_kmedoids_Mbps;
            vessels_capacity_from_abs_fuzzmeans_no_sap_from_tbs_scenario_ml(iter, power_iter, vessel) = all_vessels_UEs_v3(vessel).final_capacity_downlink_fuzzymeans_Mbps;
            vessels_capacity_from_abs_kmeans_GA_sap_from_tbs_scenario_ml(iter, power_iter, vessel) = all_vessels_UEs_GA_kmeans_v3(vessel);
            vessels_capacity_from_abs_kmedoids_GA_sap_from_tbs_scenario_ml(iter, power_iter, vessel) = all_vessels_UEs_GA_kmedoids_v3(vessel);
            vessels_capacity_from_abs_fuzzmeans_GA_sap_from_tbs_scenario_ml(iter, power_iter, vessel) = all_vessels_UEs_GA_fuzzy_means_v3(vessel);
        end
    end
end

% START PLOTTING
% ---------------------------------------------------------------
% ---------------------------------------------------------------
% ---------------------------------------------------------------

% START PLOTTING FOR COMBINED VESSEL SUM RATE
% ---------------------------------------------------------------
% Power settings
abs_power_ranges = [0.001, 0.01, 0.1, 1, 4, 10];  % in Watts
abs_power_ranges_dBm = 10 * log10(abs_power_ranges * 1000);  % in dBm

figure; hold on;

% 1. NAP (TBS Only)
avg_vessel_capacity_tbs_only = mean(vessels_capacity_from_tbs_basic_scenario_no_abs(:));

% To avoid overlapping clutter at start, shift slightly the x-points (or use semilogx safely)
semilogx(abs_power_ranges_dBm, repmat(avg_vessel_capacity_tbs_only, 1, length(abs_power_ranges_dBm)), ...
    'r-o', 'DisplayName', 'Baseline - NUP');

% 2. RAP
%avg_vessel_capacity_abs_uniform_no_sap = mean(mean(vessels_capacity_from_abs_random_no_sap_from_tbs_scenario_abs, 3), 1);
%semilogx(abs_power_ranges_dBm, avg_vessel_capacity_abs_uniform_no_sap, 'g-s', 'DisplayName', 'RAP');

% 3. RAP-GA-SAP
%avg_vessel_capacity_abs_uniform_GA_sap = mean(mean(vessels_capacity_from_abs_random_GA_sap_from_tbs_scenario_abs, 3), 1);
%semilogx(abs_power_ranges_dBm, avg_vessel_capacity_abs_uniform_GA_sap, 'g--s', 'DisplayName', 'RAP-GA-SAP');

% 4. GGAP
%avg_vessel_capacity_abs_grid_no_sap = mean(mean(vessels_capacity_from_abs_grid_no_sap_from_tbs_scenario_abs, 3), 1);
%semilogx(abs_power_ranges_dBm, avg_vessel_capacity_abs_grid_no_sap, 'b-^', 'DisplayName', 'GGAP');

% 5. GGAP-GA-SAP
%avg_vessel_capacity_abs_grid_GA_sap = mean(mean(vessels_capacity_from_abs_grid_GA_sap_from_tbs_scenario_abs, 3), 1);
%semilogx(abs_power_ranges_dBm, avg_vessel_capacity_abs_grid_GA_sap, 'b--^', 'DisplayName', 'GGAP-GA-SAP');

% 6. KMEA-AP
avg_vessel_capacity_abs_kmeans_no_sap = mean(mean(vessels_capacity_from_abs_kmeans_no_sap_from_tbs_scenario_ml, 3), 1);
semilogx(abs_power_ranges_dBm, avg_vessel_capacity_abs_kmeans_no_sap, 'm-d', 'DisplayName', 'MINTA-KMEA');

% 7. KMEA-AP-GA-SAP
%avg_vessel_capacity_abs_kmeans_GA_sap = mean(mean(vessels_capacity_from_abs_kmeans_GA_sap_from_tbs_scenario_ml, 3), 1);
%semilogx(abs_power_ranges_dBm, avg_vessel_capacity_abs_kmeans_GA_sap, 'm--d', 'DisplayName', 'KMEA-AP-GA-SAP');

% 8. KMED-AP
avg_vessel_capacity_abs_kmedoids_no_sap = mean(mean(vessels_capacity_from_abs_kmedoids_no_sap_from_tbs_scenario_ml, 3), 1);
semilogx(abs_power_ranges_dBm, avg_vessel_capacity_abs_kmedoids_no_sap, 'c-v', 'DisplayName', 'MINTA-KMED');

% 9. KMED-AP-GA-SAP
%avg_vessel_capacity_abs_kmedoids_GA_sap = mean(mean(vessels_capacity_from_abs_kmedoids_GA_sap_from_tbs_scenario_ml, 3), 1);
%semilogx(abs_power_ranges_dBm, avg_vessel_capacity_abs_kmedoids_GA_sap, 'c--v', 'DisplayName', 'KMED-AP-GA-SAP');

% 10. FM-AP
avg_vessel_capacity_abs_fuzzy_no_sap = mean(mean(vessels_capacity_from_abs_fuzzmeans_no_sap_from_tbs_scenario_ml, 3), 1);
semilogx(abs_power_ranges_dBm, avg_vessel_capacity_abs_fuzzy_no_sap, 'k-p', 'DisplayName', 'MINTA-FCM');

% 11. FM-AP-GA-SAP
%avg_vessel_capacity_abs_fuzzy_GA_sap = mean(mean(vessels_capacity_from_abs_fuzzmeans_GA_sap_from_tbs_scenario_ml, 3), 1);
%semilogx(abs_power_ranges_dBm, avg_vessel_capacity_abs_fuzzy_GA_sap, 'k--p', 'DisplayName', 'FM-AP-GA-SAP');

% X-axis formatting
xticks(abs_power_ranges_dBm);
xticklabels(arrayfun(@(x) sprintf('%.1f', x), abs_power_ranges_dBm, 'UniformOutput', false));

xlabel('$P_{ABS}$ [dBm]', 'Interpreter', 'latex');
ylabel('Vessels Average Downlink Rate [Mbps]');
legend('show', 'Location', 'best');
grid on;


% END PLOTTING FOR COMBINED VESSEL SUM RATE
% ---------------------------------------------------------------












num_abs_values = length(NoABS_values);
% Initialize capacity arrays for different ABS configurations
vessels_capacity_from_tbs_basic_scenario_no_abs = zeros(Monte_carlo_N_iterations, num_abs_values, N_vessels);

vessels_capacity_from_abs_random_no_sap_from_tbs_scenario_abs = zeros(Monte_carlo_N_iterations, num_abs_values, N_vessels);
vessels_capacity_from_abs_grid_no_sap_from_tbs_scenario_abs = zeros(Monte_carlo_N_iterations, num_abs_values, N_vessels);
vessels_capacity_from_abs_random_GA_sap_from_tbs_scenario_abs = zeros(Monte_carlo_N_iterations, num_abs_values, N_vessels);
vessels_capacity_from_abs_grid_GA_sap_from_tbs_scenario_abs = zeros(Monte_carlo_N_iterations, num_abs_values, N_vessels);

% Machine Learning-based ABS Placement
vessels_capacity_from_abs_kmeans_no_sap_from_tbs_scenario_ml = zeros(Monte_carlo_N_iterations, num_abs_values, N_vessels);
vessels_capacity_from_abs_kmedoids_no_sap_from_tbs_scenario_ml = zeros(Monte_carlo_N_iterations, num_abs_values, N_vessels);
vessels_capacity_from_abs_fuzzmeans_no_sap_from_tbs_scenario_ml = zeros(Monte_carlo_N_iterations, num_abs_values, N_vessels);
vessels_capacity_from_abs_kmeans_GA_sap_from_tbs_scenario_ml = zeros(Monte_carlo_N_iterations, num_abs_values, N_vessels);
vessels_capacity_from_abs_kmedoids_GA_sap_from_tbs_scenario_ml = zeros(Monte_carlo_N_iterations, num_abs_values, N_vessels);
vessels_capacity_from_abs_fuzzmeans_GA_sap_from_tbs_scenario_ml = zeros(Monte_carlo_N_iterations, num_abs_values, N_vessels);

% START MONTE CARLO SIMULATION 2
for iter = 1:Monte_carlo_N_iterations
    % First procedure to produce the hotspot centers and vessels inside the hotspots.
    [TBS1, TBS2, TBS3, all_vessels_UEs, vessel_hotspots, vessel_hotspots_UEs, outer_vessel_UEs, number_outer_vessel] = topology_initializer(Area_min_m, Area_max_m, N_vessels, N_vessel_hotspots, Lambda, ...
        Vessel_hotspots_radius_m, TBS_1_BW_Hz, TBS_1_Fc_Hz, TBS_1_Pt_dBm, TBS_2_BW_Hz, TBS_2_Fc_Hz, TBS_2_Pt_dBm, TBS_3_BW_Hz, TBS_3_Fc_Hz, TBS_3_Pt_dBm, TBS_height_m, TBS_1_Pt_Watt, TBS_2_Pt_Watt, TBS_3_Pt_Watt);

    for m_idx = 1:length(NoABS_values)
        M = NoABS_values(m_idx);

        % Call Baseline clusterings to produce places for all the ABSs.
        [ABS_placement_data_uniform, vessel_associations_uniform] = random_uniform(Area_min_m, Area_max_m, M, all_vessels_UEs, ABS_height_m);
        [ABS_placement_data_grid, vessel_associations_grid] = grid_placement(Area_min_m, Area_max_m, M, all_vessels_UEs, ABS_height_m);

        % Call ML models to produce places for all the ABSs.
        [ABS_placement_data_Kmeans, vessel_associations_kmeans] = ul_abs_clustering('kmeans', all_vessels_UEs, M, ABS_height_m, abs_cluster_vessels_limit);
        [ABS_placement_data_kmedoids, vessel_associations_kmedoids] = ul_abs_clustering('kmedoids', all_vessels_UEs, M, ABS_height_m, abs_cluster_vessels_limit);
        [ABS_placement_data_fuzzymeans, vessel_associations_fuzzy_means] = ul_abs_clustering('fuzzy', all_vessels_UEs, M, ABS_height_m, abs_cluster_vessels_limit);

        % Basic scenario - Vessels served by 3 TBSs only
        all_vessels_UEs_v1 = basic_scenario_runner_no_abs(all_vessels_UEs, N_vessels, TBS_height_m, TBS1, TBS2, TBS3, TBS_1_BW_Hz, TBS_2_BW_Hz, TBS_3_BW_Hz, No_Watt_Hz, Maritime_loss_dB, ...
            Sea_attenuation_dB, Vessel_antenna_height_m, Reference_distance_tbs_vessel_m);
        for vessel = 1:N_vessels
            vessels_capacity_from_tbs_basic_scenario_no_abs(iter, m_idx, vessel) = all_vessels_UEs_v1(vessel).capacity_vessel_Mbps;
        end

        % Call Clustering ABS scenario - Random & Grid Clusterings.
        [abs_relay_struct_v1, all_vessels_UEs_v2] = scenario_runner_with_baseline_clusterings_abs(ABS_placement_data_uniform, ABS_placement_data_grid, TBS1, TBS2, TBS3, ABS_height_m, TBS_1_BW_Hz, ...
            TBS_2_BW_Hz, TBS_3_BW_Hz, M, No_Watt_Hz, vessel_associations_uniform, vessel_associations_grid, all_vessels_UEs, ABS_fc_Hz, ABS_Pt_Watt, ABS_BW_Hz, N_vessels, ABS_Pt_Watt);

        % No Spectrum Allocation Policy
        for vessel = 1:N_vessels
            vessels_capacity_from_abs_random_no_sap_from_tbs_scenario_abs(iter, m_idx, vessel) = all_vessels_UEs_v2(vessel).final_capacity_downlink_uniform_Mbps;
            vessels_capacity_from_abs_grid_no_sap_from_tbs_scenario_abs(iter, m_idx, vessel) = all_vessels_UEs_v2(vessel).final_capacity_downlink_grid_Mbps;
        end

        % Genetic Algorithm Spectrum Allocation Policy - GA-SAP
        [~, all_vessels_UEs_GA_uniform_v2] = genetic_heuristic_spectrum_allocator_uniform(abs_relay_struct_v1, all_vessels_UEs_v2, ABS_placement_data_uniform, ABS_BW_Hz, No_Watt_Hz, vessel_associations_uniform, ...
            ABS_Pt_Watt, ABS_height_m, ABS_fc_Hz, M);
        [~, all_vessels_UEs_GA_grid_v2] = genetic_heuristic_spectrum_allocator_grid(abs_relay_struct_v1, all_vessels_UEs_v2, ABS_placement_data_grid, ABS_BW_Hz, No_Watt_Hz, vessel_associations_grid, ...
            ABS_Pt_Watt, ABS_height_m, ABS_fc_Hz, M);

        for vessel = 1:N_vessels
            vessels_capacity_from_abs_random_GA_sap_from_tbs_scenario_abs(iter, m_idx, vessel) = all_vessels_UEs_GA_uniform_v2(vessel);
            vessels_capacity_from_abs_grid_GA_sap_from_tbs_scenario_abs(iter, m_idx, vessel) = all_vessels_UEs_GA_grid_v2(vessel);
        end

        % Call ML-based ABS scenario (KMEANS, KMEDOIDS, FUZZY-MEANS).
        [abs_relay_struct_v2, all_vessels_UEs_v3] = scenario_runner_with__ml_abs(ABS_placement_data_Kmeans, ABS_placement_data_kmedoids, ABS_placement_data_fuzzymeans, TBS1, TBS2, TBS3, ABS_height_m, TBS_1_BW_Hz, ...
            TBS_2_BW_Hz, TBS_3_BW_Hz, M, No_Watt_Hz, vessel_associations_kmeans, vessel_associations_kmedoids, vessel_associations_fuzzy_means, all_vessels_UEs, ABS_fc_Hz, ABS_Pt_Watt, ABS_BW_Hz, N_vessels, ABS_Pt_Watt);

        % GA-SAP for ML-based scenario
        [~, all_vessels_UEs_GA_kmeans_v3] = genetic_heuristic_spectrum_allocator_kmeans(abs_relay_struct_v2, all_vessels_UEs_v3, ABS_placement_data_Kmeans, ABS_BW_Hz, No_Watt_Hz, vessel_associations_kmeans, ...
            ABS_Pt_Watt, ABS_height_m, ABS_fc_Hz, M);
        [~, all_vessels_UEs_GA_kmedoids_v3] = genetic_heuristic_spectrum_allocator_kmedoids(abs_relay_struct_v2, all_vessels_UEs_v3, ABS_placement_data_kmedoids, ABS_BW_Hz, No_Watt_Hz, vessel_associations_kmedoids, ...
            ABS_Pt_Watt, ABS_height_m, ABS_fc_Hz, M);
        [~, all_vessels_UEs_GA_fuzzmeans_v3] = genetic_heuristic_spectrum_allocator_fuzzy_means(abs_relay_struct_v2, all_vessels_UEs_v3, ABS_placement_data_fuzzymeans, ABS_BW_Hz, No_Watt_Hz, vessel_associations_fuzzy_means, ...
            ABS_Pt_Watt, ABS_height_m, ABS_fc_Hz, M);

        % Extract capacities for ML models
        for vessel = 1:N_vessels
            vessels_capacity_from_abs_kmeans_no_sap_from_tbs_scenario_ml(iter, m_idx, vessel) = all_vessels_UEs_v3(vessel).final_capacity_downlink_kmeans_Mbps;
            vessels_capacity_from_abs_kmedoids_no_sap_from_tbs_scenario_ml(iter, m_idx, vessel) = all_vessels_UEs_v3(vessel).final_capacity_downlink_kmedoids_Mbps;
            vessels_capacity_from_abs_fuzzmeans_no_sap_from_tbs_scenario_ml(iter, m_idx, vessel) = all_vessels_UEs_v3(vessel).final_capacity_downlink_fuzzymeans_Mbps;
            vessels_capacity_from_abs_kmeans_GA_sap_from_tbs_scenario_ml(iter, m_idx, vessel) = all_vessels_UEs_GA_kmeans_v3(vessel);
            vessels_capacity_from_abs_kmedoids_GA_sap_from_tbs_scenario_ml(iter, m_idx, vessel) = all_vessels_UEs_GA_kmedoids_v3(vessel);
            vessels_capacity_from_abs_fuzzmeans_GA_sap_from_tbs_scenario_ml(iter, m_idx, vessel) = all_vessels_UEs_GA_fuzzmeans_v3(vessel);
        end
    end
end


% === INPUT DATA ===
avg_downlink_vessel_capacity = zeros(length(NoABS_values), 11);

% Assign each scheme
avg_downlink_vessel_capacity(:, 1) = squeeze(mean(vessels_capacity_from_tbs_basic_scenario_no_abs, 3))';        % NAP
avg_downlink_vessel_capacity(:, 2) = squeeze(mean(mean(vessels_capacity_from_abs_random_no_sap_from_tbs_scenario_abs, 3), 1))';  % RAP
avg_downlink_vessel_capacity(:, 3) = squeeze(mean(mean(vessels_capacity_from_abs_random_GA_sap_from_tbs_scenario_abs, 3), 1))';  % RAP-GA-SAP
avg_downlink_vessel_capacity(:, 4) = squeeze(mean(mean(vessels_capacity_from_abs_grid_no_sap_from_tbs_scenario_abs, 3), 1))';    % GGAP
avg_downlink_vessel_capacity(:, 5) = squeeze(mean(mean(vessels_capacity_from_abs_grid_GA_sap_from_tbs_scenario_abs, 3), 1))';    % GGAP-GA-SAP
avg_downlink_vessel_capacity(:, 6) = squeeze(mean(mean(vessels_capacity_from_abs_kmeans_no_sap_from_tbs_scenario_ml, 3), 1))';   % KMEA-AP
avg_downlink_vessel_capacity(:, 7) = squeeze(mean(mean(vessels_capacity_from_abs_kmeans_GA_sap_from_tbs_scenario_ml, 3), 1))';   % KMEA-AP-GA-SAP
avg_downlink_vessel_capacity(:, 8) = squeeze(mean(mean(vessels_capacity_from_abs_kmedoids_no_sap_from_tbs_scenario_ml, 3), 1))'; % KMED-AP
avg_downlink_vessel_capacity(:, 9) = squeeze(mean(mean(vessels_capacity_from_abs_kmedoids_GA_sap_from_tbs_scenario_ml, 3), 1))'; % KMED-AP-GA-SAP
avg_downlink_vessel_capacity(:,10) = squeeze(mean(mean(vessels_capacity_from_abs_fuzzmeans_no_sap_from_tbs_scenario_ml, 3), 1))';% FM-AP
avg_downlink_vessel_capacity(:,11) = squeeze(mean(mean(vessels_capacity_from_abs_fuzzmeans_GA_sap_from_tbs_scenario_ml, 3), 1))';% FM-AP-GA-SAP



% === CONFIG (Updated) ===
% Removed: RAP (2, 3) and GGAP (4, 5)
methods_without_GASAP = [1 6 8 10];   % NAP, KMEA-AP, KMED-AP, FM-AP
methods_with_GASAP =    [7 9 11];     % KMEA-AP-GA-SAP, KMED-AP-GA-SAP, FM-AP-GA-SAP
cmap = lines(11);  % Reuse same color map

% === FIGURE 1: Without GA-SAP (Full Interference) ===
figure;
set(gcf, 'Position', [100 100 700 500]);

h1 = bar(NoABS_values, avg_downlink_vessel_capacity(:, methods_without_GASAP), 'grouped', 'BarWidth', 0.85);
for i = 1:length(h1)
    h1(i).FaceColor = cmap(methods_without_GASAP(i), :);
end

xlabel('Number of UAVs [#]', 'FontSize', 13);
ylabel('Avg Vessel Downlink Rate [Mbps]', 'FontSize', 13);
title('ABS Placement - Without Spectrum Allocation (Full Interference)', 'FontSize', 14);
legend({'NAP','KMEA-AP','KMED-AP','FM-AP'}, 'FontSize', 11, 'Location', 'southoutside');
grid on; box on;
set(gca, 'FontSize', 12, 'YScale', 'log', 'YMinorGrid', 'on');
xticks(NoABS_values);
xtickangle(0);
set(gcf, 'Color', 'w');

% === FIGURE 2: With GA-SAP (Spectrum Allocation) ===
figure;
set(gcf, 'Position', [850 100 700 500]);

h2 = bar(NoABS_values, avg_downlink_vessel_capacity(:, methods_with_GASAP), 'grouped', 'BarWidth', 0.85);
for i = 1:length(h2)
    h2(i).FaceColor = cmap(methods_with_GASAP(i), :);
end

xlabel('Number of UAVs [#]', 'FontSize', 13);
ylabel('Avg Vessel Downlink Rate [Mbps]', 'FontSize', 13);
title('ABS Placement - With Spectrum Allocation (GA-SAP)', 'FontSize', 14);
legend({'KMEA-AP-GA-SAP','KMED-AP-GA-SAP','FM-AP-GA-SAP'}, 'FontSize', 11, 'Location', 'southoutside');
grid on; box on;
set(gca, 'FontSize', 12, 'YScale', 'log', 'YMinorGrid', 'on');
xticks(NoABS_values);
xtickangle(0);
set(gcf, 'Color', 'w');









num_bw_values = length(BW_range);
% Initialize capacity arrays for different ABS configurations
vessels_capacity_from_tbs_basic_scenario_no_abs = zeros(Monte_carlo_N_iterations, num_bw_values, N_vessels); % Add M index here

vessels_capacity_from_abs_random_no_sap_from_tbs_scenario_abs = zeros(Monte_carlo_N_iterations, num_bw_values, N_vessels);
vessels_capacity_from_abs_grid_no_sap_from_tbs_scenario_abs = zeros(Monte_carlo_N_iterations, num_bw_values, N_vessels);
vessels_capacity_from_abs_random_GA_sap_from_tbs_scenario_abs = zeros(Monte_carlo_N_iterations, num_bw_values, N_vessels);
vessels_capacity_from_abs_grid_GA_sap_from_tbs_scenario_abs = zeros(Monte_carlo_N_iterations, num_bw_values, N_vessels);

% Machine Learning-based ABS Placement
vessels_capacity_from_abs_kmeans_no_sap_from_tbs_scenario_ml = zeros(Monte_carlo_N_iterations, num_bw_values, N_vessels);
vessels_capacity_from_abs_kmedoids_no_sap_from_tbs_scenario_ml = zeros(Monte_carlo_N_iterations, num_bw_values, N_vessels);
vessels_capacity_from_abs_fuzzmeans_no_sap_from_tbs_scenario_ml = zeros(Monte_carlo_N_iterations, num_bw_values, N_vessels);
vessels_capacity_from_abs_kmeans_GA_sap_from_tbs_scenario_ml = zeros(Monte_carlo_N_iterations, num_bw_values, N_vessels);
vessels_capacity_from_abs_kmedoids_GA_sap_from_tbs_scenario_ml = zeros(Monte_carlo_N_iterations, num_bw_values, N_vessels);
vessels_capacity_from_abs_fuzzmeans_GA_sap_from_tbs_scenario_ml = zeros(Monte_carlo_N_iterations, num_bw_values, N_vessels);

% START MONTE CARLO SIMULATION 3
% ============================================================
% -------------------------------------------------------------
% -------------------------------------------------------------
% -------------------------------------------------------------
for iter = 1:Monte_carlo_N_iterations
    % First procedure here is to produce the hotspot centers and
    % the Vessels inside the hotspots.
    % -----------------------------------------------------------
    % Call 'topology_initializer.m' function to create & deploy TBSs, Vessels, and
    % vessel hotspots.
    [TBS1, TBS2, TBS3, all_vessels_UEs, vessel_hotspots, vessel_hotspots_UEs, outer_vessel_UEs, number_outer_vessel] = topology_initializer(Area_min_m, Area_max_m, N_vessels, N_vessel_hotspots, Lambda, ...
        Vessel_hotspots_radius_m, TBS_1_BW_Hz, TBS_1_Fc_Hz, TBS_1_Pt_dBm, TBS_2_BW_Hz, TBS_2_Fc_Hz, TBS_2_Pt_dBm, TBS_3_BW_Hz, TBS_3_Fc_Hz, TBS_3_Pt_dBm, TBS_height_m, TBS_1_Pt_Watt, TBS_2_Pt_Watt, TBS_3_Pt_Watt);

    for m_idx = 1:length(BW_range)
        BWs = BW_range(m_idx);
        % -----------------------------------------------------------
        % Call 2 Baseline clusterings to produce places for all the ABSs.
        [ABS_placement_data_uniform, vessel_associations_uniform] = random_uniform(Area_min_m, Area_max_m, N_abs, all_vessels_UEs, ABS_height_m);
        [ABS_placement_data_grid, vessel_associations_grid] = grid_placement(Area_min_m, Area_max_m, N_abs, all_vessels_UEs, ABS_height_m);

        % -----------------------------------------------------------
        % Call the 3 ML models to produce places for all the ABSs.
        [ABS_placement_data_Kmeans, vessel_associations_kmeans] = ul_abs_clustering('kmeans', all_vessels_UEs, N_abs, ABS_height_m);
        [ABS_placement_data_kmedoids, vessel_associations_kmedoids] = ul_abs_clustering('kmedoids', all_vessels_UEs, N_abs, ABS_height_m);
        [ABS_placement_data_fuzzymeans, vessel_associations_fuzzy_means] = ul_abs_clustering('fuzzy', all_vessels_UEs, N_abs, ABS_height_m);

        % Call basic scenario.
        % Basic Scenario here. Only Vessels served by 3 TBSs.
        % --------------------------------------------------
        all_vessels_UEs_v1 = basic_scenario_runner_no_abs(all_vessels_UEs, N_vessels, TBS_height_m, TBS1, TBS2, TBS3, TBS_1_BW_Hz, TBS_2_BW_Hz, TBS_3_BW_Hz, No_Watt_Hz, Maritime_loss_dB, ...
            Sea_attenuation_dB, Vessel_antenna_height_m, Reference_distance_tbs_vessel_m);
        % Extract capacities from updated struct
        for vessel = 1:N_vessels
            vessels_capacity_from_tbs_basic_scenario_no_abs(iter, m_idx, vessel) = all_vessels_UEs_v1(vessel).capacity_vessel_Mbps;
        end


        % Call 2 Clustering ABSs scenario. - Random & Grid Clusterings.
        % Clustering ABS Scenario here. Vessels now served by ABSs.
        % ------------------------------------------------------------
        [abs_relay_struct_v1, all_vessels_UEs_v2] = scenario_runner_with_baseline_clusterings_abs(ABS_placement_data_uniform, ABS_placement_data_grid, TBS1, TBS2, TBS3, ABS_height_m, TBS_1_BW_Hz, ...
            TBS_2_BW_Hz, TBS_3_BW_Hz, N_abs, No_Watt_Hz, vessel_associations_uniform, vessel_associations_grid, all_vessels_UEs, ABS_fc_Hz, ABS_Pt_Watt, BWs, N_vessels, ABS_Pt_Watt);
        % Genetic Algorithm Spectrum Allocation Policy - GA-SAP.
        [~, all_vessels_UEs_GA_uniform_v2] = genetic_heuristic_spectrum_allocator_uniform(abs_relay_struct_v1, all_vessels_UEs_v2, ABS_placement_data_uniform, BWs, No_Watt_Hz, vessel_associations_uniform, ...
            ABS_Pt_Watt, ABS_height_m, ABS_fc_Hz, N_abs);
        [~, all_vessels_UEs_GA_grid_v2] = genetic_heuristic_spectrum_allocator_grid(abs_relay_struct_v1, all_vessels_UEs_v2, ABS_placement_data_grid, BWs, No_Watt_Hz, vessel_associations_grid, ABS_Pt_Watt, ...
            ABS_height_m, ABS_fc_Hz, N_abs);
        % Extract capacities from updated struct
        for vessel = 1:N_vessels
            vessels_capacity_from_abs_random_no_sap_from_tbs_scenario_abs(iter, m_idx, vessel) = all_vessels_UEs_v2(vessel).final_capacity_downlink_uniform_Mbps;
            vessels_capacity_from_abs_grid_no_sap_from_tbs_scenario_abs(iter, m_idx, vessel) = all_vessels_UEs_v2(vessel).final_capacity_downlink_grid_Mbps;
            vessels_capacity_from_abs_random_GA_sap_from_tbs_scenario_abs(iter, m_idx, vessel) = all_vessels_UEs_GA_uniform_v2(vessel);
            vessels_capacity_from_abs_grid_GA_sap_from_tbs_scenario_abs(iter, m_idx, vessel) = all_vessels_UEs_GA_grid_v2(vessel);
        end


        % Call 3 ML ABSs scenario. KMEANS, KMEDOIDS AND FUZZY-MEANS.
        % 3 ML ABS Scenario here. Vessels now served by ABSs.
        % ---------------------------------------------------------
        [abs_relay_struct_v2, all_vessels_UEs_v3] = scenario_runner_with__ml_abs(ABS_placement_data_Kmeans, ABS_placement_data_kmedoids, ABS_placement_data_fuzzymeans, TBS1, TBS2, TBS3, ABS_height_m, TBS_1_BW_Hz, ...
            TBS_2_BW_Hz, TBS_3_BW_Hz, N_abs, No_Watt_Hz, vessel_associations_kmeans, vessel_associations_kmedoids, vessel_associations_fuzzy_means, all_vessels_UEs, ABS_fc_Hz, ABS_Pt_Watt, ABS_BW_Hz, N_vessels, ABS_Pt_Watt);
        % Genetic Algorithm Spectrum Allocation Policy - GA-SAP.
        [~, all_vessels_UEs_GA_kmeans_v3] = genetic_heuristic_spectrum_allocator_kmeans(abs_relay_struct_v2, all_vessels_UEs_v3, ABS_placement_data_Kmeans, BWs, No_Watt_Hz, vessel_associations_kmeans, ...
            ABS_Pt_Watt, ABS_height_m, ABS_fc_Hz, N_abs);
        [~, all_vessels_UEs_GA_kmedoids_v3] = genetic_heuristic_spectrum_allocator_kmedoids(abs_relay_struct_v2, all_vessels_UEs_v3, ABS_placement_data_kmedoids, BWs, No_Watt_Hz, vessel_associations_kmedoids, ...
            ABS_Pt_Watt, ABS_height_m, ABS_fc_Hz, N_abs);
        [~, all_vessels_UEs_GA_fuzzmeans_v3] = genetic_heuristic_spectrum_allocator_fuzzy_means(abs_relay_struct_v2, all_vessels_UEs_v3, ABS_placement_data_fuzzymeans, BWs, No_Watt_Hz, vessel_associations_fuzzy_means, ...
            ABS_Pt_Watt, ABS_height_m, ABS_fc_Hz, N_abs);
        % Extract capacities from updated struct
        for vessel = 1:N_vessels
            vessels_capacity_from_abs_kmeans_no_sap_from_tbs_scenario_ml(iter, m_idx, vessel) = all_vessels_UEs_v3(vessel).final_capacity_downlink_kmeans_Mbps;
            vessels_capacity_from_abs_kmedoids_no_sap_from_tbs_scenario_ml(iter, m_idx, vessel) = all_vessels_UEs_v3(vessel).final_capacity_downlink_kmedoids_Mbps;
            vessels_capacity_from_abs_fuzzmeans_no_sap_from_tbs_scenario_ml(iter, m_idx, vessel) = all_vessels_UEs_v3(vessel).final_capacity_downlink_fuzzymeans_Mbps;
            vessels_capacity_from_abs_kmeans_GA_sap_from_tbs_scenario_ml(iter, m_idx, vessel) = all_vessels_UEs_GA_kmeans_v3(vessel);
            vessels_capacity_from_abs_kmedoids_GA_sap_from_tbs_scenario_ml(iter, m_idx, vessel) = all_vessels_UEs_GA_kmedoids_v3(vessel);
            vessels_capacity_from_abs_fuzzmeans_GA_sap_from_tbs_scenario_ml(iter, m_idx, vessel) = all_vessels_UEs_GA_fuzzmeans_v3(vessel);
        end
    end
end



% Preallocate average capacity matrix: [num_bandwidths x num_schemes]
avg_downlink_vessel_capacity = zeros(length(BW_range), 11);

% Assign average vessel capacities across schemes (squeezed and transposed where needed)
avg_downlink_vessel_capacity(:, 1)  = squeeze(mean(vessels_capacity_from_tbs_basic_scenario_no_abs, 3)).';                                % NAP
avg_downlink_vessel_capacity(:, 2)  = squeeze(mean(mean(vessels_capacity_from_abs_random_no_sap_from_tbs_scenario_abs, 3), 1)).';         % RAP
avg_downlink_vessel_capacity(:, 3)  = squeeze(mean(mean(vessels_capacity_from_abs_random_GA_sap_from_tbs_scenario_abs, 3), 1)).';         % RAP-GA-SAP
avg_downlink_vessel_capacity(:, 4)  = squeeze(mean(mean(vessels_capacity_from_abs_grid_no_sap_from_tbs_scenario_abs, 3), 1)).';           % GGAP
avg_downlink_vessel_capacity(:, 5)  = squeeze(mean(mean(vessels_capacity_from_abs_grid_GA_sap_from_tbs_scenario_abs, 3), 1)).';           % GGAP-GA-SAP
avg_downlink_vessel_capacity(:, 6)  = squeeze(mean(mean(vessels_capacity_from_abs_kmeans_no_sap_from_tbs_scenario_ml, 3), 1)).';          % KMEA-AP
avg_downlink_vessel_capacity(:, 7)  = squeeze(mean(mean(vessels_capacity_from_abs_kmeans_GA_sap_from_tbs_scenario_ml, 3), 1)).';          % KMEA-AP-GA-SAP
avg_downlink_vessel_capacity(:, 8)  = squeeze(mean(mean(vessels_capacity_from_abs_kmedoids_no_sap_from_tbs_scenario_ml, 3), 1)).';        % KMED-AP
avg_downlink_vessel_capacity(:, 9)  = squeeze(mean(mean(vessels_capacity_from_abs_kmedoids_GA_sap_from_tbs_scenario_ml, 3), 1)).';        % KMED-AP-GA-SAP
avg_downlink_vessel_capacity(:, 10) = squeeze(mean(mean(vessels_capacity_from_abs_fuzzmeans_no_sap_from_tbs_scenario_ml, 3), 1)).';       % FM-AP
avg_downlink_vessel_capacity(:, 11) = squeeze(mean(mean(vessels_capacity_from_abs_fuzzmeans_GA_sap_from_tbs_scenario_ml, 3), 1)).';       % FM-AP-GA-SAP

% Create bar plot
figure('Color', 'w'); hold on;

% Define consistent color map
cmap = lines(11);

% Create grouped bar plot
b = bar(BW_range / 1e6, avg_downlink_vessel_capacity, 'grouped');

% Apply custom color per scheme
for i = 1:numel(b)
    b(i).FaceColor = cmap(i, :);
end

% Label axes
xlabel('Bandwidth [MHz]', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('Vessel Average Downlink Rate [Mbps]', 'FontSize', 12, 'FontWeight', 'bold');

% Set x-axis ticks and labels (in MHz)
xticks(BW_range / 1e6);
xtickangle(0);

% Add legend with professional formatting
legend({'NAP', 'RAP', 'RAP-GA-SAP', 'GGAP', 'GGAP-GA-SAP', ...
        'KMEA-AP', 'KMEA-AP-GA-SAP', 'KMED-AP', 'KMED-AP-GA-SAP', ...
        'FM-AP', 'FM-AP-GA-SAP'}, ...
        'Location', 'northwest', 'FontSize', 10, 'NumColumns', 2);

% Enhance grid and axes
grid on;
box on;
set(gca, 'FontSize', 11, 'LineWidth', 1);

% Set Y-limits with 10% headroom
ylim([0, ceil(max(avg_downlink_vessel_capacity(:)) * 1.1)]);

























% START PLOTTING FOR CDF - PDF
% ---------------------------------------------------------------
% --- Configuration ---
target_power = 20; % Watts
abs_power_ranges = [5, 10, 15, 20, 25, 30]; % Ensure this matches your simulation
% Assuming your capacity result matrices are named as in your previous code
% --- Find Power Level Index ---
power_level_index = find(abs_power_ranges == target_power);
if isempty(power_level_index)
    error(['Power level ' num2str(target_power) ' not found in abs_power_ranges.']);
end
% --- Extract Data at Target Power ---
% Vessels
vessel_sum_rates_tbs_only = vessels_capacity_from_tbs_basic_scenario_no_abs(:, power_level_index, :);
all_vessel_capacities_tbs_only = vessel_sum_rates_tbs_only(:);
vessel_sum_rates_uniform = vessels_capacity_from_abs_random_from_tbs_scenario_abs(:, power_level_index, :);
all_vessel_capacities_uniform = vessel_sum_rates_uniform(:);
vessel_sum_rates_grid = vessels_capacity_from_abs_grid_from_tbs_scenario_abs(:, power_level_index, :);
all_vessel_capacities_grid = vessel_sum_rates_grid(:);
vessel_sum_rates_kmeans = vessels_capacity_from_abs_kmeans_from_tbs_scenario_ml_abs(:, power_level_index, :);
all_vessel_capacities_kmeans = vessel_sum_rates_kmeans(:);
vessel_sum_rates_kmedoids = vessels_capacity_from_abs_kmedoids_from_tbs_scenario_ml_abs(:, power_level_index, :);
all_vessel_capacities_kmedoids = vessel_sum_rates_kmedoids(:);
vessel_sum_rates_fuzzy = vessels_capacity_from_abs_fuzzy_means_from_tbs_scenario_ml_abs(:, power_level_index, :);
all_vessel_capacities_fuzzy = vessel_sum_rates_fuzzy(:);
% ABSs
abs_sum_rates_uniform = abs_capacity_from_tbs_uniform_scenario_abs(:, power_level_index, :);
all_abs_capacities_uniform = abs_sum_rates_uniform(:);
abs_sum_rates_grid = abs_capacity_from_tbs_grid_scenario_abs(:, power_level_index, :);
all_abs_capacities_grid = abs_sum_rates_grid(:);
abs_sum_rates_kmeans = abs_capacity_from_tbs_kmeans_scenario_ml_abs(:, power_level_index, :);
all_abs_capacities_kmeans = abs_sum_rates_kmeans(:);
abs_sum_rates_kmedoids = abs_capacity_from_tbs_kmedoids_scenario_ml_abs(:, power_level_index, :);
all_abs_capacities_kmedoids = abs_sum_rates_kmedoids(:);
abs_sum_rates_fuzzy = abs_capacity_from_tbs_fuzzy_means_scenario_ml_abs(:, power_level_index, :);
all_abs_capacities_fuzzy = abs_sum_rates_fuzzy(:);

% --- Plotting ---
% 1. CDF for Vessels at 20 Watts
figure;
[f_tbs, x_tbs] = ecdf(all_vessel_capacities_tbs_only);
plot(x_tbs, f_tbs, 'r-', 'DisplayName', 'NAP');
hold on;
[f_uniform, x_uniform] = ecdf(all_vessel_capacities_uniform);
plot(x_uniform, f_uniform, 'g-', 'DisplayName', 'RAP');
[f_grid, x_grid] = ecdf(all_vessel_capacities_grid);
plot(x_grid, f_grid, 'b-', 'DisplayName', 'GGAP');
[f_kmeans, x_kmeans] = ecdf(all_vessel_capacities_kmeans);
plot(x_kmeans, f_kmeans, 'm-', 'DisplayName', 'KMEA-AP');
[f_kmedoids, x_kmedoids] = ecdf(all_vessel_capacities_kmedoids);
plot(x_kmedoids, f_kmedoids, 'c-', 'DisplayName', 'KMED-AP');
[f_fuzzy, x_fuzzy] = ecdf(all_vessel_capacities_fuzzy);
plot(x_fuzzy, f_fuzzy, 'k-', 'DisplayName', 'FM-AP');
hold off;
xlabel('Vessels Average Downlink Rate [Mbps]');
ylabel('Cumulative Probability');
% title(['CDF of Vessel Sum Rate at TBS Power = ' num2str(target_power) 'W']);
legend('show', 'Location', 'best');
grid on;

% 2. PDF for Vessels at 20 Watts (using kernel density)
figure;
[density_tbs, x_tbs_pdf] = ksdensity(all_vessel_capacities_tbs_only);
plot(x_tbs_pdf, density_tbs, 'r-', 'DisplayName', 'NAP');
hold on;
[density_uniform, x_uniform_pdf] = ksdensity(all_vessel_capacities_uniform);
plot(x_uniform_pdf, density_uniform, 'g-', 'DisplayName', 'RAP');
[density_grid, x_grid_pdf] = ksdensity(all_vessel_capacities_grid);
plot(x_grid_pdf, density_grid, 'b-', 'DisplayName', 'GGAP');
[density_kmeans, x_kmeans_pdf] = ksdensity(all_vessel_capacities_kmeans);
plot(x_kmeans_pdf, density_kmeans, 'm-', 'DisplayName', 'KMEA-AP');
[density_kmedoids, x_kmedoids_pdf] = ksdensity(all_vessel_capacities_kmedoids);
plot(x_kmedoids_pdf, density_kmedoids, 'c-', 'DisplayName', 'KMED-AP');
[density_fuzzy, x_fuzzy_pdf] = ksdensity(all_vessel_capacities_fuzzy);
plot(x_fuzzy_pdf, density_fuzzy, 'k-', 'DisplayName', 'FM-AP');
hold off;
xlabel('Vessels Average Downlink Rate [Mbps]');
ylabel('Probability Density');
%title(['Estimated PDF of Vessel Sum Rate at TBS Power = ' num2str(target_power) 'W']);
legend('show', 'Location', 'best');
grid on;
% ---------------------------------------------------------------


%}










% Finally, end measuring time.
% ---------------------------------------------------------------------------
elapsed_seconds = toc;
% Calculate days, hours, minutes, and remaining seconds
days = floor(elapsed_seconds / (24 * 3600));
remaining_seconds = mod(elapsed_seconds, (24 * 3600));
hours = floor(remaining_seconds / 3600);
remaining_seconds = mod(remaining_seconds, 3600);
minutes = floor(remaining_seconds / 60);
seconds = mod(remaining_seconds, 60);
% Format the output string
elapsed_time_str = sprintf(['Elapsed time: %d days, %d hours, ' ...
    '%d minutes, %.3f seconds'], ...
    days, hours, minutes, seconds);
% Log total time elapsed.
logger("Total simulation time elapsed with execID -> " + execID + " is -> " ...
    + elapsed_time_str);
% Calculate and log mem used.
% ----------------------------------------------------
logger("Total simulation memory with execID -> " + execID + " is -> "...
    + string(memory().MemUsedMATLAB / 1e6) + " MB" );
% Log the final output of the simulation execution now and, Bye :*.
logger("Completing 6G-MATINA Simulator -> " + execID);
logger("---------------------------------- ");
logger("---------------------------------- ");
logger("---------------------------------- ");

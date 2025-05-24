clc;
clear all;

addpath('simulation\');
addpath('config\');
addpath(genpath('clustering\'));
addpath(genpath('channel\'));
addpath('visulization\');
addpath('optimizers\');
addpath('test\');


% Read 'configuration.m'
run('configuration.m');  % Load variables from 'configuration.m'

% Call 'topology_initializer.m' function to create & deploy TBSs, Vessels, and
% vessel hotspots.
% -----------------------------------------------------------------------------
[TBS1, TBS2, TBS3, all_vessels_UEs, vessel_hotspots, vessel_hotspots_UEs, outer_vessel_UEs, number_outer_vessel] = topology_initializer(Area_min_m, ...
    Area_max_m, N_vessels, N_vessel_hotspots, Lambda, Vessel_hotspots_radius_m, TBS_1_BW_Hz, TBS_1_Fc_Hz, ...
    TBS_1_Pt_dBm, TBS_2_BW_Hz, TBS_2_Fc_Hz, TBS_2_Pt_dBm, TBS_3_BW_Hz, TBS_3_Fc_Hz, TBS_3_Pt_dBm, TBS_height_m, ...
    TBS_1_Pt_Watt, TBS_2_Pt_Watt, TBS_3_Pt_Watt);

% Call the 3 ML models to produce places for all the ABSs.
% -------------------------------------------------------------------------
[ABS_placement_data_Kmeans, vessel_associations_kmeans] = ul_abs_clustering('kmeans', all_vessels_UEs, N_abs, ABS_height_m, abs_cluster_vessels_limit);
[ABS_placement_data_kmedoids, vessel_associations_kmedoids] = ul_abs_clustering('kmedoids', all_vessels_UEs, N_abs, ABS_height_m, abs_cluster_vessels_limit);
[ABS_placement_data_fuzzymeans, vessel_associations_fuzzy_means] = ul_abs_clustering('fuzzy', all_vessels_UEs, N_abs, ABS_height_m, abs_cluster_vessels_limit);

[abs_relay_struct_v2, all_vessels_UEs_v3] = scenario_runner_with__ml_abs(ABS_placement_data_Kmeans, ABS_placement_data_kmedoids, ABS_placement_data_fuzzymeans, TBS1, TBS2, TBS3, ABS_height_m, TBS_1_BW_Hz, ...
    TBS_2_BW_Hz, TBS_3_BW_Hz, N_abs, No_Watt_Hz, vessel_associations_kmeans, vessel_associations_kmedoids, vessel_associations_fuzzy_means, all_vessels_UEs, ABS_fc_Hz, ABS_Pt_Watt, ABS_BW_Hz, N_vessels, 15);

% Genetic Algorithm Spectrum Allocation Policy - GA-SAP.
% -------------------------------------------------------
[~, all_vessels_UEs_GA_kmeans_v3] = genetic_heuristic_spectrum_allocator_kmeans(abs_relay_struct_v2, all_vessels_UEs_v3, ABS_placement_data_Kmeans, ABS_BW_Hz, No_Watt_Hz, vessel_associations_kmeans, ...
            ABS_Pt_Watt, ABS_height_m, ABS_fc_Hz, N_abs, abs_cluster_vessels_limit);


% Downlink Rates of UAVs with 3 MLs
% ------------------------------------------------------------------
abs_rates_kmeans = [abs_relay_struct_v2.capacity_kmeans_Mbps];
% abs_rates_kmedoids = [abs_relay_struct_v2.capacity_kmedoids_Mbps];
% abs_rates_fuzzy = [abs_relay_struct_v2.capacity_fuzzymeans_Mbps];

% Downlink Rates of All Vessels with 3 MLs
% ------------------------------------------------------------------------
vessel_rates_kmeans = [all_vessels_UEs_v3.final_capacity_downlink_kmeans_Mbps];
% vessel_rates_kmedoids = [all_vessels_UEs_v3.final_capacity_downlink_kmedoids_Mbps];
% vessel_rates_fuzzy = [all_vessels_UEs_v3.final_capacity_downlink_fuzzymeans_Mbps];

% Average Downlink Rates of ALL Vessels with 3 MLs
% ------------------------------------------------------------------------
avg_vessel_kmeans = mean(vessel_rates_kmeans);
% avg_vessel_kmedoids = mean(vessel_rates_kmedoids);
% avg_vessel_fuzzy = mean(vessel_rates_fuzzy);


basic_ploter_ML_ABS(Area_min_m, Area_max_m, TBS1, TBS2, TBS3, vessel_hotspots, Vessel_hotspots_radius_m, vessel_hotspots_UEs, outer_vessel_UEs, N_abs, ABS_placement_data_fuzzymeans, ...
    ABS_placement_data_Kmeans, ABS_placement_data_kmedoids, abs_relay_struct_v2);


avg_vessel_rate_ga = mean([all_vessels_UEs_GA_kmeans_v3.updated_capacity_Mbps]);

% Create a bar plot
figure;
bar([1, 2, 3], [mean(abs_rates_kmeans), avg_vessel_kmeans, avg_vessel_rate_ga]);
% Customize the plot
% Customize x-axis tick labels
set(gca, 'XTick', [1 2 3], ...
         'XTickLabel', {'Average ABS Downlink Rate (Mbps)', ...
                        'Average Vessel Downlink Rate (Mbps) (F.I. No GA)', ...
                        'Average Vessel Downlink Rate (Mbps) (GA)'});

ylabel('Downlink Rate (Mbps)');
title('Average Downlink Rates (K-Means with GA Spectrum Allocation)');
grid on;
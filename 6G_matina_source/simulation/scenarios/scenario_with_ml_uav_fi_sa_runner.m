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
function [dl_vessels_rate_with_no_uav_list, dl_vessels_rate_with_ml_uav_kmeans_fi_list,...
    dl_vessels_rate_with_ml_uav_kmedoids_fi_list, dl_vessels_rate_with_ml_uav_fcm_fi_list,...
    dl_vessels_rate_with_ml_uav_kmeans_sa_list, dl_vessels_rate_with_ml_uav_kmedoids_sa_list,...
    dl_vessels_rate_with_ml_uav_fcm_sa_list, dl_uavs_rate_with_ml_uav_kmeans_list,... 
    dl_uavs_rate_with_ml_uav_kmedoids_list, dl_uavs_rate_with_ml_uav_fcm_list] = scenario_with_ml_uav_fi_sa_runner(...
    monte_carlo_iterations_N, area_min_m, area_max_m, total_vessels_N, uav_N, abs_height_m, abs_fc_Hz,...
    abs_BW_Hz, abs_Pt_Watt, abs_cluster_vessels_limit_N, vessel_hotspots_N, lambda_N_vessels, ...
    vessel_hotspots_radius_m, tbs_1_BW_Hz, tbs_1_Fc_Hz, tbs_1_Pt_dBm, tbs_2_BW_Hz,...
    tbs_2_Fc_Hz, tbs_2_Pt_dBm, tbs_3_BW_Hz, tbs_3_Fc_Hz,...
    tbs_3_Pt_dBm, tbs_1_Pt_Watt, tbs_2_Pt_Watt, tbs_3_Pt_Watt, tbs_height_m,...
    noise_Watt_Hz, maritime_loss_dB, sea_attenuation_dB, vessel_antenna_height_m,...
    reference_distance_tbs_vessel_m)
% Here, we simulate all the flow simmulation including Monte Carlo
% for the basic scenario which is vessels, and ML-deployed UAVs/ABSs
% into the maritime grid. Once we calculate downlink rates
% for all UAVs and Vessels, then we re-run it for N MCarlo iterations
% to export statistics and visualize them!
% Store capacity results
% 7 schemes-structs for Downlink Vessels Rate
% --------------------------------------------------------------------------
dl_vessels_rate_with_no_uav_list = zeros(monte_carlo_iterations_N, total_vessels_N);
dl_vessels_rate_with_ml_uav_kmeans_fi_list = zeros(monte_carlo_iterations_N, total_vessels_N);
dl_vessels_rate_with_ml_uav_kmedoids_fi_list = zeros(monte_carlo_iterations_N, total_vessels_N);
dl_vessels_rate_with_ml_uav_fcm_fi_list = zeros(monte_carlo_iterations_N, total_vessels_N);
dl_vessels_rate_with_ml_uav_kmeans_sa_list = zeros(monte_carlo_iterations_N, total_vessels_N);
dl_vessels_rate_with_ml_uav_kmedoids_sa_list = zeros(monte_carlo_iterations_N, total_vessels_N);
dl_vessels_rate_with_ml_uav_fcm_sa_list = zeros(monte_carlo_iterations_N, total_vessels_N);
% 3 schemes-structs for Downlink UAVs Rate
% --------------------------------------------------------------------------
dl_uavs_rate_with_ml_uav_kmeans_list = zeros(monte_carlo_iterations_N, total_vessels_N);
dl_uavs_rate_with_ml_uav_kmedoids_list = zeros(monte_carlo_iterations_N, total_vessels_N);
dl_uavs_rate_with_ml_uav_fcm_list = zeros(monte_carlo_iterations_N, total_vessels_N);

for iter = 1:monte_carlo_iterations_N
    % First step is to produce the hotspot centers and
    % the Vessels inside, outside the hotspots.
    % Call 'topology_initializer.m' function to create & deploy TBSs, Vessels, and
    % vessel hotspots.   
    % ----------------------------------------------------------------------------
    [TBS1, TBS2, TBS3, total_vessel_ue_in_out_hotspots, vessel_hotspots, ...
    vessel_ue_in_hotspots, vessel_ue_out_hotspots, number_of_vessels_ue_out_hotspots,...
    number_of_vessels_ue_in_hotspots] = topology_initializer(area_min_m, ...
        area_max_m, total_vessels_N, vessel_hotspots_N, lambda_N_vessels, ...
        vessel_hotspots_radius_m, tbs_1_BW_Hz, tbs_1_Fc_Hz, tbs_1_Pt_dBm, ...
        tbs_2_BW_Hz, tbs_2_Fc_Hz, tbs_2_Pt_dBm, tbs_3_BW_Hz, tbs_3_Fc_Hz,...
        tbs_3_Pt_dBm, tbs_height_m, tbs_1_Pt_Watt, tbs_2_Pt_Watt, tbs_3_Pt_Watt);
    % Call the 3 ML models for ABSs placement.
    % ----------------------------------------------------------------------------
    [uavs_placement_data_kmeans, uav_vessel_assignments_kmeans] = ul_abs_clustering('kmeans',...
        total_vessel_ue_in_out_hotspots, uav_N, abs_height_m, abs_cluster_vessels_limit_N);
    [uavs_placement_data_kmedoids, uav_vessel_assignments_kmedoids] = ul_abs_clustering('kmedoids',...
        total_vessel_ue_in_out_hotspots, uav_N, abs_height_m, abs_cluster_vessels_limit_N);
    [uavs_placement_data_fcm, uav_vessel_assignments_fcm] = ul_abs_clustering('fuzzy',...
        total_vessel_ue_in_out_hotspots, uav_N, abs_height_m, abs_cluster_vessels_limit_N);
    % Run network without UAVs. Vessels served only by 3 TBSs.
    % ----------------------------------------------------------------------------
    total_vessel_ue_in_out_hotspots_v1 = network_with_no_uav_runner(total_vessel_ue_in_out_hotspots,...
        total_vessels_N, tbs_height_m, TBS1, TBS2, TBS3, noise_Watt_Hz, maritime_loss_dB, ...
        sea_attenuation_dB, vessel_antenna_height_m, reference_distance_tbs_vessel_m);
    % Save results in list.
    % --------------------
    for vessel = 1:total_vessels_N
        dl_vessels_rate_with_no_uav_list(iter, vessel) = total_vessel_ue_in_out_hotspots_v1(vessel).capacity_vessel_Mbps;
    end
    % Run network with 3 UAVs placement and also with f.i.
    % ----------------------------------------------------------------------------
    [uavs_relay_struct, total_vessel_ue_in_out_hotspots_v2] = network_with_ml_uav_fi_runner(uavs_placement_data_kmeans,...
        uavs_placement_data_kmedoids, uavs_placement_data_fcm, TBS1, TBS2, TBS3,...
        abs_height_m, uav_N, noise_Watt_Hz, uav_vessel_assignments_kmeans, uav_vessel_assignments_kmedoids,...
        uav_vessel_assignments_fcm, total_vessel_ue_in_out_hotspots_v1, abs_fc_Hz, abs_Pt_Watt, abs_BW_Hz,...
        total_vessels_N);
    % Save results in lists.
    % First, for the dl of the vessels for each ML UAV placement.
    % ----------------------------------------------------------
    for vessel = 1:total_vessels_N
        dl_vessels_rate_with_ml_uav_kmeans_fi_list(iter, vessel) = total_vessel_ue_in_out_hotspots_v2(vessel).final_capacity_downlink_kmeans_Mbps;
        dl_vessels_rate_with_ml_uav_kmedoids_fi_list(iter, vessel) = total_vessel_ue_in_out_hotspots_v2(vessel).final_capacity_downlink_kmedoids_Mbps;
        dl_vessels_rate_with_ml_uav_fcm_fi_list(iter, vessel) = total_vessel_ue_in_out_hotspots_v2(vessel).final_capacity_downlink_fuzzymeans_Mbps;
    end
    % Secondly, for the dl of the UAVs for each ML UAV placement.
    % ----------------------------------------------------------
    for uav = 1:uav_N
        dl_uavs_rate_with_ml_uav_kmeans_list(iter, vessuavl) = uavs_relay_struct(uav).final_capacity_downlink_kmeans_Mbps;
        dl_uavs_rate_with_ml_uav_kmedoids_list(iter, uav) = uavs_relay_struct(uav).final_capacity_downlink_kmedoids_Mbps;
        dl_uavs_rate_with_ml_uav_fcm_list(iter, uav) = uavs_relay_struct(uav).final_capacity_downlink_fuzzymeans_Mbps;
    end
    % Run network with 3 UAVs placement and also with s.a. - Genetic Algorithm
    % ----------------------------------------------------------------------------
    [~, total_vessel_ue_in_out_hotspots_kmeans_ga] = genetic_heuristic_spectrum_allocator_kmeans(uavs_relay_struct,...
        total_vessel_ue_in_out_hotspots_v2, uavs_placement_data_kmeans, abs_BW_Hz, noise_Watt_Hz, uav_vessel_assignments_kmeans, ...
        abs_Pt_Watt, abs_height_m, abs_fc_Hz, uav_N, abs_cluster_vessels_limit_N);
    [~, total_vessel_ue_in_out_hotspots_kmedoids_ga] = genetic_heuristic_spectrum_allocator_kmedoids(uavs_relay_struct,...
        total_vessel_ue_in_out_hotspots_v2, uavs_placement_data_kmedoids, abs_BW_Hz, noise_Watt_Hz, uav_vessel_assignments_kmedoids,...
        abs_Pt_Watt, abs_height_m, abs_fc_Hz, uav_N, abs_cluster_vessels_limit_N);
    [~, total_vessel_ue_in_out_hotspots_fcm_ga] = genetic_heuristic_spectrum_allocator_fuzzy_means(uavs_relay_struct,...
        total_vessel_ue_in_out_hotspots_v2, uavs_placement_data_fcm, abs_BW_Hz, noise_Watt_Hz, uav_vessel_assignments_fcm,...
        abs_Pt_Watt, abs_height_m, abs_fc_Hz, uav_N, abs_cluster_vessels_limit_N);
    % Save results in lists.
    % Only for Vessels here, UAVs are ok from TBS.
    % Vessels now have no Full Interference. Have Spectrum
    % Allocation.
    % ----------------------------------------------------------
    for vessel = 1:N_vessels
        dl_vessels_rate_with_ml_uav_kmeans_sa_list(iter, vessel) = total_vessel_ue_in_out_hotspots_kmeans_ga(vessel).final_capacity_downlink_kmeans_Mbps;
        dl_vessels_rate_with_ml_uav_kmedoids_sa_list(iter, vessel) = total_vessel_ue_in_out_hotspots_kmedoids_ga(vessel).final_capacity_downlink_kmedoids_Mbps;
        dl_vessels_rate_with_ml_uav_fcm_sa_list(iter, vessel) = total_vessel_ue_in_out_hotspots_fcm_ga(vessel).final_capacity_downlink_fuzzymeans_Mbps;
    end
end
end

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
clear all;
clc;
% Add paths including folders and sub-folders.
% By alphabetic order.
addpath(genpath('channel\'));
addpath(genpath('clustering\'));
addpath(genpath('config\'));
addpath(genpath('logging\'));
addpath(genpath('logs\'));
addpath(genpath('optimizers\'));
addpath(genpath('simulation\'));
addpath(genpath('test\'));
addpath(genpath('visulization\'));
% Scenario with vessels and ML UAVs FI just to test visualizations
% -------------------------------------------------------------
% Call configuration to read the variables conf
run('configuration.m');
% Call topology initializer
% ----------------------------------------------------------------------------
[TBS1, TBS2, TBS3, total_vessel_ue_in_out_hotspots, vessel_hotspots, ...
    vessel_ue_in_hotspots, vessel_ue_out_hotspots, number_of_vessels_ue_out_hotspots,...
    number_of_vessels_ue_in_hotspots] = topology_initializer(area_min_m_conf, ...
    area_max_m_conf, total_vessels_N_conf, vessel_hotspots_N_conf, lambda_N_vessels_conf, ...
    vessel_hotspots_radius_m_conf, tbs_1_BW_Hz_conf, tbs_1_Fc_Hz_conf, tbs_1_Pt_dBm_conf, ...
    tbs_2_BW_Hz_conf, tbs_2_Fc_Hz_conf, tbs_2_Pt_dBm_conf, tbs_3_BW_Hz_conf, tbs_3_Fc_Hz_conf,...
    tbs_3_Pt_dBm_conf, tbs_height_m_conf, tbs_1_Pt_Watt_conf, tbs_2_Pt_Watt_conf, tbs_3_Pt_Watt_conf);
% Call the 3 ML models for ABSs placement.
% ----------------------------------------------------------------------------
[uavs_placement_data_kmeans, uav_vessel_assignments_kmeans] = ul_abs_clustering('kmeans',...
    total_vessel_ue_in_out_hotspots, uav_N_conf, abs_height_m_conf, abs_cluster_vessels_limit_N_conf);
[uavs_placement_data_kmedoids, uav_vessel_assignments_kmedoids] = ul_abs_clustering('kmedoids',...
    total_vessel_ue_in_out_hotspots, uav_N_conf, abs_height_m_conf, abs_cluster_vessels_limit_N_conf);
[uavs_placement_data_fcm, uav_vessel_assignments_fcm] = ul_abs_clustering('fuzzy',...
    total_vessel_ue_in_out_hotspots, uav_N_conf, abs_height_m_conf, abs_cluster_vessels_limit_N_conf);
% Run network without UAVs. Vessels served only by 3 TBSs.
% ----------------------------------------------------------------------------
total_vessel_ue_in_out_hotspots_v1 = network_with_no_uav_runner(total_vessel_ue_in_out_hotspots,...
    total_vessels_N_conf, tbs_height_m_conf, TBS1, TBS2, TBS3, noise_Watt_Hz_conf, maritime_loss_dB_conf, ...
    sea_attenuation_dB_conf, vessel_antenna_height_m_conf, reference_distance_tbs_vessel_m_conf);
% Run network with 3 UAVs placement and also with f.i.
% ----------------------------------------------------------------------------
[uavs_relay_struct, total_vessel_ue_in_out_hotspots_v2] = network_with_ml_uav_fi_runner(uavs_placement_data_kmeans,...
    uavs_placement_data_kmedoids, uavs_placement_data_fcm, TBS1, TBS2, TBS3,...
    abs_height_m_conf, uav_N_conf, noise_Watt_Hz_conf, uav_vessel_assignments_kmeans, uav_vessel_assignments_kmedoids,...
    uav_vessel_assignments_fcm, total_vessel_ue_in_out_hotspots_v1, abs_fc_Hz_conf, abs_Pt_Watt_conf, abs_BW_Hz_conf,...
    total_vessels_N_conf);
% Call topology ploter to see the network!!!
% For testing purposes
% --------------------------------------------------------------------------
topology_with_vessels_uavs_ploter(area_min_m_conf, area_max_m_conf, TBS1, TBS2, TBS3,...
    vessel_hotspots, vessel_hotspots_radius_m_conf, vessel_ue_in_hotspots,...
    vessel_ue_out_hotspots, uav_N_conf, uavs_placement_data_fcm, ...
    uavs_placement_data_kmeans, uavs_placement_data_kmedoids, uavs_relay_struct)
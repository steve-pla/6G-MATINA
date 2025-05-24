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
function [uavs_relay_struct, total_vessel_ue_in_out_hotspots] = network_with_ml_uav_fi_runner(uavs_placement_data_kmeans,...
    uavs_placement_data_kmedoids, uavs_placement_data_fcm, TBS1, TBS2, TBS3, abs_height_m, ...
    uav_N, noise_Watt_Hz, uav_vessel_assignments_kmeans, uav_vessel_assignments_kmedoids, uav_vessel_assignments_fcm,...
    total_vessel_ue_in_out_hotspots, abs_fc_Hz, abs_Pt_Watt, abs_BW_Hz, total_vessels_N)
% To hold for each ABS which TBS is serving, create a temp 2d array
abs_tbs_association_kmeans = zeros(5,2);  % Preallocate space for efficiency
abs_tbs_association_kmedoids = zeros(5,2);  % Preallocate space for efficiency
abs_tbs_association_fuzzymeans = zeros(5,2);  % Preallocate space for efficiency 
% 4th Step
% ---------------------------------------------------------------
% Create struct for the ABS
uavs_relay_struct = struct([]);
for i = 1 : uav_N
    uavs_relay_struct(i).id = i;
    % ------------------------------------------------------------------------------------------------------
    % a. Calculate distance between TBSs and ABSs.
    uavs_relay_struct(i).distance_2D_tbs1_kmeans_m = pdist([uavs_placement_data_kmeans(i).x, uavs_placement_data_kmeans(i).y; TBS1.x, TBS1.y]);
    uavs_relay_struct(i).distance_3D_tbs1_kmeans_m = pdist([uavs_placement_data_kmeans(i).x, uavs_placement_data_kmeans(i).y, uavs_placement_data_kmeans(i).z; TBS1.x, TBS1.y, TBS1.z]);
    uavs_relay_struct(i).distance_2D_tbs2_kmeans_m = pdist([uavs_placement_data_kmeans(i).x, uavs_placement_data_kmeans(i).y; TBS2.x, TBS2.y]);
    uavs_relay_struct(i).distance_3D_tbs2_kmeans_m = pdist([uavs_placement_data_kmeans(i).x, uavs_placement_data_kmeans(i).y, uavs_placement_data_kmeans(i).z; TBS2.x, TBS2.y, TBS2.z]);
    uavs_relay_struct(i).distance_2D_tbs3_kmeans_m = pdist([uavs_placement_data_kmeans(i).x, uavs_placement_data_kmeans(i).y; TBS3.x, TBS3.y]);
    uavs_relay_struct(i).distance_3D_tbs3_kmeans_m = pdist([uavs_placement_data_kmeans(i).x, uavs_placement_data_kmeans(i).y, uavs_placement_data_kmeans(i).z; TBS3.x, TBS3.y, TBS3.z]);

    uavs_relay_struct(i).distance_2D_tbs1_kmedoids_m = pdist([uavs_placement_data_kmedoids(i).x, uavs_placement_data_kmedoids(i).y; TBS1.x, TBS1.y]);
    uavs_relay_struct(i).distance_3D_tbs1_kmedoids_m = pdist([uavs_placement_data_kmedoids(i).x, uavs_placement_data_kmedoids(i).y, uavs_placement_data_kmedoids(i).z; TBS1.x, TBS1.y, TBS1.z]);
    uavs_relay_struct(i).distance_2D_tbs2_kmedoids_m = pdist([uavs_placement_data_kmedoids(i).x, uavs_placement_data_kmedoids(i).y; TBS2.x, TBS2.y]);
    uavs_relay_struct(i).distance_3D_tbs2_kmedoids_m = pdist([uavs_placement_data_kmedoids(i).x, uavs_placement_data_kmedoids(i).y, uavs_placement_data_kmedoids(i).z; TBS2.x, TBS2.y, TBS2.z]);
    uavs_relay_struct(i).distance_2D_tbs3_kmedoids_m = pdist([uavs_placement_data_kmedoids(i).x, uavs_placement_data_kmedoids(i).y; TBS3.x, TBS3.y]);
    uavs_relay_struct(i).distance_3D_tbs3_kmedoids_m = pdist([uavs_placement_data_kmedoids(i).x, uavs_placement_data_kmedoids(i).y, uavs_placement_data_kmedoids(i).z; TBS3.x, TBS3.y, TBS3.z]);

    uavs_relay_struct(i).distance_2D_tbs1_fuzzymeans_m = pdist([uavs_placement_data_fcm(i).x, uavs_placement_data_fcm(i).y; TBS1.x, TBS1.y]);
    uavs_relay_struct(i).distance_3D_tbs1_fuzzymeans_m = pdist([uavs_placement_data_fcm(i).x, uavs_placement_data_fcm(i).y, uavs_placement_data_fcm(i).z; TBS1.x, TBS1.y, TBS1.z]);
    uavs_relay_struct(i).distance_2D_tbs2_fuzzymeans_m = pdist([uavs_placement_data_fcm(i).x, uavs_placement_data_fcm(i).y; TBS2.x, TBS2.y]);
    uavs_relay_struct(i).distance_3D_tbs2_fuzzymeans_m = pdist([uavs_placement_data_fcm(i).x, uavs_placement_data_fcm(i).y, uavs_placement_data_fcm(i).z; TBS2.x, TBS2.y, TBS2.z]);
    uavs_relay_struct(i).distance_2D_tbs3_fuzzymeans_m = pdist([uavs_placement_data_fcm(i).x, uavs_placement_data_fcm(i).y; TBS3.x, TBS3.y]);
    uavs_relay_struct(i).distance_3D_tbs3_fuzzymeans_m = pdist([uavs_placement_data_fcm(i).x, uavs_placement_data_fcm(i).y, uavs_placement_data_fcm(i).z; TBS3.x, TBS3.y, TBS3.z]);
    % ------------------------------------------------------------------------------------------------------
    % b. Calculate PL between TBSs and ABSs.
    uavs_relay_struct(i).path_loss_tbs1_kmeans_dB = A2G_maritime(uavs_relay_struct(i).distance_2D_tbs1_kmeans_m, abs_height_m, TBS1.Fc_Hz);
    uavs_relay_struct(i).path_loss_tbs1_kmeans_pure = 10^(uavs_relay_struct(i).path_loss_tbs1_kmeans_dB/10);
    uavs_relay_struct(i).path_loss_tbs2_kmeans_dB = A2G_maritime(uavs_relay_struct(i).distance_2D_tbs2_kmeans_m, abs_height_m, TBS2.Fc_Hz);
    uavs_relay_struct(i).path_loss_tbs2_kmeans_pure = 10^(uavs_relay_struct(i).path_loss_tbs2_kmeans_dB/10);
    uavs_relay_struct(i).path_loss_tbs3_kmeans_dB = A2G_maritime(uavs_relay_struct(i).distance_2D_tbs3_kmeans_m, abs_height_m, TBS3.Fc_Hz);
    uavs_relay_struct(i).path_loss_tbs3_kmeans_pure = 10^(uavs_relay_struct(i).path_loss_tbs3_kmeans_dB/10);

    uavs_relay_struct(i).path_loss_tbs1_kmedoids_dB = A2G_maritime(uavs_relay_struct(i).distance_2D_tbs1_kmedoids_m, abs_height_m, TBS1.Fc_Hz);
    uavs_relay_struct(i).path_loss_tbs1_kmedoids_pure = 10^(uavs_relay_struct(i).path_loss_tbs1_kmedoids_dB/10);
    uavs_relay_struct(i).path_loss_tbs2_kmedoids_dB = A2G_maritime(uavs_relay_struct(i).distance_2D_tbs2_kmedoids_m, abs_height_m, TBS2.Fc_Hz);
    uavs_relay_struct(i).path_loss_tbs2_kmedoids_pure = 10^(uavs_relay_struct(i).path_loss_tbs2_kmedoids_dB/10);
    uavs_relay_struct(i).path_loss_tbs3_kmedoids_dB = A2G_maritime(uavs_relay_struct(i).distance_2D_tbs3_kmedoids_m, abs_height_m, TBS3.Fc_Hz);
    uavs_relay_struct(i).path_loss_tbs3_kmedoids_pure = 10^(uavs_relay_struct(i).path_loss_tbs3_kmedoids_dB/10);

    uavs_relay_struct(i).path_loss_tbs1_fuzzymeans_dB = A2G_maritime(uavs_relay_struct(i).distance_2D_tbs1_fuzzymeans_m, abs_height_m, TBS1.Fc_Hz);
    uavs_relay_struct(i).path_loss_tbs1_fuzzymeans_pure = 10^(uavs_relay_struct(i).path_loss_tbs1_fuzzymeans_dB/10);
    uavs_relay_struct(i).path_loss_tbs2_fuzzymeans_dB = A2G_maritime(uavs_relay_struct(i).distance_2D_tbs2_fuzzymeans_m, abs_height_m, TBS2.Fc_Hz);
    uavs_relay_struct(i).path_loss_tbs2_fuzzymeans_pure = 10^(uavs_relay_struct(i).path_loss_tbs2_fuzzymeans_dB/10);
    uavs_relay_struct(i).path_loss_tbs3_fuzzymeans_dB = A2G_maritime(uavs_relay_struct(i).distance_2D_tbs3_fuzzymeans_m, abs_height_m, TBS3.Fc_Hz);
    uavs_relay_struct(i).path_loss_tbs3_fuzzymeans_pure = 10^(uavs_relay_struct(i).path_loss_tbs3_fuzzymeans_dB/10);
    % ------------------------------------------------------------------------------------------------------
    % c. Calculate Rayleigh coefficient parameter
    % Rayleigh Fading Coefficients with Zero Mean and Variance 1
    uavs_relay_struct(i).fading_tbs1_kmeans = Rayleigh_fading_coefficients();
    uavs_relay_struct(i).fading_tbs2_kmeans = Rayleigh_fading_coefficients();
    uavs_relay_struct(i).fading_tbs3_kmeans = Rayleigh_fading_coefficients();

    uavs_relay_struct(i).fading_tbs1_kmedoids = Rayleigh_fading_coefficients();
    uavs_relay_struct(i).fading_tbs2_kmedoids = Rayleigh_fading_coefficients();
    uavs_relay_struct(i).fading_tbs3_kmedoids = Rayleigh_fading_coefficients();

    uavs_relay_struct(i).fading_tbs1_fuzzymeans = Rayleigh_fading_coefficients();
    uavs_relay_struct(i).fading_tbs2_fuzzymeans = Rayleigh_fading_coefficients();
    uavs_relay_struct(i).fading_tbs3_fuzzymeans = Rayleigh_fading_coefficients();
    % ------------------------------------------------------------------------------------------------------
    % d. Calculate Channel Gain
    uavs_relay_struct(i).channel_gain_tbs1_kmeans = abs(uavs_relay_struct(i).fading_tbs1_kmeans)^2;
    uavs_relay_struct(i).channel_gain_tbs2_kmeans = abs(uavs_relay_struct(i).fading_tbs2_kmeans)^2;
    uavs_relay_struct(i).channel_gain_tbs3_kmeans = abs(uavs_relay_struct(i).fading_tbs3_kmeans)^2;

    uavs_relay_struct(i).channel_gain_tbs1_kmedoids = abs(uavs_relay_struct(i).fading_tbs1_kmedoids)^2;
    uavs_relay_struct(i).channel_gain_tbs2_kmedoids = abs(uavs_relay_struct(i).fading_tbs2_kmedoids)^2;
    uavs_relay_struct(i).channel_gain_tbs3_kmedoids = abs(uavs_relay_struct(i).fading_tbs3_kmedoids)^2;

    uavs_relay_struct(i).channel_gain_tbs1_fuzzymeans = abs(uavs_relay_struct(i).fading_tbs1_fuzzymeans)^2;
    uavs_relay_struct(i).channel_gain_tbs2_fuzzymeans = abs(uavs_relay_struct(i).fading_tbs2_fuzzymeans)^2;
    uavs_relay_struct(i).channel_gain_tbs3_fuzzymeans = abs(uavs_relay_struct(i).fading_tbs3_fuzzymeans)^2;
    % ------------------------------------------------------------------------------------------------------
    % e. Calculate Power received for each ABS from 3 TBSs (Pr).
    uavs_relay_struct(i).Pr_tbs1_kmeans_Watt = (TBS1.Pt_Watt * uavs_relay_struct(i).channel_gain_tbs1_kmeans) / uavs_relay_struct(i).path_loss_tbs1_kmeans_pure;
    uavs_relay_struct(i).Pr_tbs2_kmeans_Watt = (TBS2.Pt_Watt * uavs_relay_struct(i).channel_gain_tbs2_kmeans)/ uavs_relay_struct(i).path_loss_tbs2_kmeans_pure;
    uavs_relay_struct(i).Pr_tbs3_kmeans_Watt = (TBS3.Pt_Watt * uavs_relay_struct(i).channel_gain_tbs3_kmeans)/ uavs_relay_struct(i).path_loss_tbs3_kmeans_pure;

    uavs_relay_struct(i).Pr_tbs1_kmedoids_Watt = (TBS1.Pt_Watt * uavs_relay_struct(i).channel_gain_tbs1_kmedoids)/ uavs_relay_struct(i).path_loss_tbs1_kmedoids_pure;
    uavs_relay_struct(i).Pr_tbs2_kmedoids_Watt = (TBS2.Pt_Watt * uavs_relay_struct(i).channel_gain_tbs2_kmedoids)/ uavs_relay_struct(i).path_loss_tbs2_kmedoids_pure;
    uavs_relay_struct(i).Pr_tbs3_kmedoids_Watt = (TBS3.Pt_Watt * uavs_relay_struct(i).channel_gain_tbs3_kmedoids)/ uavs_relay_struct(i).path_loss_tbs3_kmedoids_pure;

    uavs_relay_struct(i).Pr_tbs1_fuzzymeans_Watt = (TBS1.Pt_Watt * uavs_relay_struct(i).channel_gain_tbs1_fuzzymeans)/ uavs_relay_struct(i).path_loss_tbs1_fuzzymeans_pure;
    uavs_relay_struct(i).Pr_tbs2_fuzzymeans_Watt = (TBS2.Pt_Watt * uavs_relay_struct(i).channel_gain_tbs2_fuzzymeans)/ uavs_relay_struct(i).path_loss_tbs2_fuzzymeans_pure;
    uavs_relay_struct(i).Pr_tbs3_fuzzymeans_Watt = (TBS3.Pt_Watt * uavs_relay_struct(i).channel_gain_tbs3_fuzzymeans)/ uavs_relay_struct(i).path_loss_tbs3_fuzzymeans_pure;
    % ------------------------------------------------------------------------------------------------------
    % f. Calculate SNR between TBSs and ABSs.
    uavs_relay_struct(i).SNR_tbs1_kmeans_pure = uavs_relay_struct(i).Pr_tbs1_kmeans_Watt / (noise_Watt_Hz * TBS1.BW_Hz);
    uavs_relay_struct(i).SNR_tbs2_kmeans_pure = uavs_relay_struct(i).Pr_tbs2_kmeans_Watt / (noise_Watt_Hz * TBS2.BW_Hz);
    uavs_relay_struct(i).SNR_tbs3_kmeans_pure = uavs_relay_struct(i).Pr_tbs3_kmeans_Watt / (noise_Watt_Hz * TBS3.BW_Hz);

    uavs_relay_struct(i).SNR_tbs1_kmedoids_pure = uavs_relay_struct(i).Pr_tbs1_kmedoids_Watt / (noise_Watt_Hz * TBS1.BW_Hz);
    uavs_relay_struct(i).SNR_tbs2_kmedoids_pure = uavs_relay_struct(i).Pr_tbs2_kmedoids_Watt / (noise_Watt_Hz * TBS2.BW_Hz);
    uavs_relay_struct(i).SNR_tbs3_kmedoids_pure = uavs_relay_struct(i).Pr_tbs3_kmedoids_Watt / (noise_Watt_Hz * TBS3.BW_Hz);

    uavs_relay_struct(i).SNR_tbs1_fuzzymeans_pure = uavs_relay_struct(i).Pr_tbs1_fuzzymeans_Watt / (noise_Watt_Hz * TBS1.BW_Hz);
    uavs_relay_struct(i).SNR_tbs2_fuzzymeans_pure = uavs_relay_struct(i).Pr_tbs2_fuzzymeans_Watt / (noise_Watt_Hz * TBS2.BW_Hz);
    uavs_relay_struct(i).SNR_tbs3_fuzzymeans_pure = uavs_relay_struct(i).Pr_tbs3_fuzzymeans_Watt / (noise_Watt_Hz * TBS3.BW_Hz);
    % ------------------------------------------------------------------------------------------------------
    % g. Selection Algorithm. Each ABS must choose 1 of 3 TBSs for DL
    % transmission. Select the TBS with the max SNR. But for each ML model.
    % So, we hve 3 max SNRs.
    [uavs_relay_struct(i).max_SNR_kmeans_pure, uavs_relay_struct(i).index_SNR_kmeans_TBS] = max([uavs_relay_struct(i).SNR_tbs1_kmeans_pure, uavs_relay_struct(i).SNR_tbs2_kmeans_pure, uavs_relay_struct(i).SNR_tbs3_kmeans_pure]);
    % Hold the association
    abs_tbs_association_kmeans(i, 1) = i;
    abs_tbs_association_kmeans(i, 2) = uavs_relay_struct(i).index_SNR_kmeans_TBS;
    [uavs_relay_struct(i).max_SNR_kmedoids_pure, uavs_relay_struct(i).index_SNR_kmedoids_TBS] = max([uavs_relay_struct(i).SNR_tbs1_kmedoids_pure, uavs_relay_struct(i).SNR_tbs2_kmedoids_pure, uavs_relay_struct(i).SNR_tbs3_kmedoids_pure]);
    % Hold the association
    abs_tbs_association_kmedoids(i, 1) = i;
    abs_tbs_association_kmedoids(i, 2) = uavs_relay_struct(i).index_SNR_kmedoids_TBS;
    [uavs_relay_struct(i).max_SNR_fuzzy_means_pure, uavs_relay_struct(i).index_SNR_fuzzymeans_TBS] = max([uavs_relay_struct(i).SNR_tbs1_fuzzymeans_pure, uavs_relay_struct(i).SNR_tbs2_fuzzymeans_pure, uavs_relay_struct(i).SNR_tbs3_fuzzymeans_pure]);
    % Hold the association
    abs_tbs_association_fuzzymeans(i, 1) = i;
    abs_tbs_association_fuzzymeans(i, 2) = uavs_relay_struct(i).index_SNR_fuzzymeans_TBS;
end
% We need to find the UAVs each TBS will serve.
% Then, for these UAVs we find the vessels they gonna serve.
% ----------------------------------------------------------
uav_vessels_counter = 0;
tbs_virtual_total_vessels_serve_kmeans = [];  
tbs_virtual_total_vessels_serve_kmedoids = []; 
tbs_virtual_total_vessels_serve_fcm = []; 
% UAVs served by each TBS (based on column 2)
% KMeans
% -------------------------------------------------------------------
tbs_1_all_uavs_serve_kmeans = abs_tbs_association_kmeans(abs_tbs_association_kmeans(:,2) == 1, 1);
tbs_2_all_uavs_serve_kmeans = abs_tbs_association_kmeans(abs_tbs_association_kmeans(:,2) == 2, 1);
tbs_3_all_uavs_serve_kmeans = abs_tbs_association_kmeans(abs_tbs_association_kmeans(:,2) == 3, 1);
% Create cell array to iterate without hardcoding
uavs_per_tbs_kmeans = {
    tbs_1_all_uavs_serve_kmeans;
    tbs_2_all_uavs_serve_kmeans;
    tbs_3_all_uavs_serve_kmeans;
};
% Loop through each TBS and its UAVs
for tbs_id = 1:3
    current_uavs = uavs_per_tbs_kmeans{tbs_id};
    % Loop for all UAVs
    for j = 1:length(current_uavs)
        uav_id = current_uavs(j);
        % Loop for all vessels for this jth UAV
        uav_vessels_counter = uav_vessels_counter + length(find(uav_vessel_assignments_kmeans == uav_id));
    end
    % Here, for each TBS we have the total vessels it virtually <serves>
    % through UAVs
    tbs_virtual_total_vessels_serve_kmeans{tbs_id} = uav_vessels_counter ;
    % Reset counter
    uav_vessels_counter = 0;
end
% KMedoids
% -------------------------------------------------------------------
tbs_1_all_uavs_serve_kmedoids = abs_tbs_association_kmedoids(abs_tbs_association_kmedoids(:,2) == 1, 1);
tbs_2_all_uavs_serve_kmedoids = abs_tbs_association_kmedoids(abs_tbs_association_kmedoids(:,2) == 2, 1);
tbs_3_all_uavs_serve_kmedoids = abs_tbs_association_kmedoids(abs_tbs_association_kmedoids(:,2) == 3, 1);
% Create cell array to iterate without hardcoding
uavs_per_tbs_kmedoids = {
    tbs_1_all_uavs_serve_kmedoids;
    tbs_2_all_uavs_serve_kmedoids;
    tbs_3_all_uavs_serve_kmedoids;
};
% Loop through each TBS and its UAVs
for tbs_id = 1:3
    current_uavs = uavs_per_tbs_kmedoids{tbs_id};
    % Loop for all UAVs
    for j = 1:length(current_uavs)
        uav_id = current_uavs(j);
        % Loop for all vessels for this jth UAV
        uav_vessels_counter = uav_vessels_counter + length(find(uav_vessel_assignments_kmedoids == uav_id));
    end
    % Here, for each TBS we have the total vessels it virtually <serves>
    % through UAVs
    tbs_virtual_total_vessels_serve_kmedoids{tbs_id} = uav_vessels_counter ;
    % Reset counter
    uav_vessels_counter = 0;
end
% Fuzzy C-Means
% -------------------------------------------------------------------
tbs_1_all_uavs_serve_fcm = abs_tbs_association_fuzzymeans(abs_tbs_association_fuzzymeans(:,2) == 1, 1);
tbs_2_all_uavs_serve_fcm = abs_tbs_association_fuzzymeans(abs_tbs_association_fuzzymeans(:,2) == 2, 1);
tbs_3_all_uavs_serve_fcm = abs_tbs_association_fuzzymeans(abs_tbs_association_fuzzymeans(:,2) == 3, 1);
% Create cell array to iterate without hardcoding
uavs_per_tbs_fcm = {
    tbs_1_all_uavs_serve_fcm;
    tbs_2_all_uavs_serve_fcm;
    tbs_3_all_uavs_serve_fcm;
};
% Loop through each TBS and its UAVs
for tbs_id = 1:3
    current_uavs = uavs_per_tbs_fcm{tbs_id};
    % Loop for all UAVs
    for j = 1:length(current_uavs)
        uav_id = current_uavs(j);
        % Loop for all vessels for this jth UAV
        uav_vessels_counter = uav_vessels_counter + length(find(uav_vessel_assignments_fcm == uav_id));
    end
    % Here, for each TBS we have the total vessels it virtually <serves>
    % through UAVs
    tbs_virtual_total_vessels_serve_fcm{tbs_id} = uav_vessels_counter ;
    % Reset counter
    uav_vessels_counter = 0;
end
% 6th Step
% ---------------------------------------------------------------
% We now can calculate Shannon Capacity for each ABS knowing the spectrum.
% ------------------------------------------------------------------------
for i = 1 : uav_N
    % KMeans
    % ---------------------------------------------------------------------
    if uavs_relay_struct(i).index_SNR_kmeans_TBS == 1
        uavs_relay_struct(i).capacity_kmeans_bps = ((TBS1.BW_Hz * length(find(uav_vessel_assignments_kmeans == i))) / tbs_virtual_total_vessels_serve_kmeans{1})*log2(1 + uavs_relay_struct(i).max_SNR_kmeans_pure);
        uavs_relay_struct(i).capacity_kmeans_Mbps = uavs_relay_struct(i).capacity_kmeans_bps / 1e6;
    elseif uavs_relay_struct(i).index_SNR_kmeans_TBS == 2
        uavs_relay_struct(i).capacity_kmeans_bps = ((TBS2.BW_Hz * length(find(uav_vessel_assignments_kmeans == i))) / tbs_virtual_total_vessels_serve_kmeans{2})*log2(1 + uavs_relay_struct(i).max_SNR_kmeans_pure);
        uavs_relay_struct(i).capacity_kmeans_Mbps = uavs_relay_struct(i).capacity_kmeans_bps / 1e6;
    elseif uavs_relay_struct(i).index_SNR_kmeans_TBS == 3
        uavs_relay_struct(i).capacity_kmeans_bps = ((TBS3.BW_Hz * length(find(uav_vessel_assignments_kmeans == i))) / tbs_virtual_total_vessels_serve_kmeans{3})*log2(1 + uavs_relay_struct(i).max_SNR_kmeans_pure);
        uavs_relay_struct(i).capacity_kmeans_Mbps = uavs_relay_struct(i).capacity_kmeans_bps / 1e6;
    end
    % KMedoids
    % ---------------------------------------------------------------------
    if uavs_relay_struct(i).index_SNR_kmedoids_TBS == 1
        uavs_relay_struct(i).capacity_kmedoids_bps = ((TBS1.BW_Hz * length(find(uav_vessel_assignments_kmedoids == i))) / tbs_virtual_total_vessels_serve_kmedoids{1})*log2(1 + uavs_relay_struct(i).max_SNR_kmedoids_pure);
        uavs_relay_struct(i).capacity_kmedoids_Mbps = uavs_relay_struct(i).capacity_kmedoids_bps / 1e6;
    elseif uavs_relay_struct(i).index_SNR_kmedoids_TBS == 2
        uavs_relay_struct(i).capacity_kmedoids_bps = ((TBS2.BW_Hz * length(find(uav_vessel_assignments_kmedoids == i))) / tbs_virtual_total_vessels_serve_kmedoids{2})*log2(1 + uavs_relay_struct(i).max_SNR_kmedoids_pure);
        uavs_relay_struct(i).capacity_kmedoids_Mbps = uavs_relay_struct(i).capacity_kmedoids_bps / 1e6;
    elseif uavs_relay_struct(i).index_SNR_kmedoids_TBS == 3
        uavs_relay_struct(i).capacity_kmedoids_bps = ((TBS3.BW_Hz * length(find(uav_vessel_assignments_kmedoids == i))) / tbs_virtual_total_vessels_serve_kmedoids{3})*log2(1 + uavs_relay_struct(i).max_SNR_kmedoids_pure);
        uavs_relay_struct(i).capacity_kmedoids_Mbps = uavs_relay_struct(i).capacity_kmedoids_bps / 1e6;
    end
    % Fuzzy C-Means
    % ---------------------------------------------------------------------
    if uavs_relay_struct(i).index_SNR_fuzzymeans_TBS == 1
        uavs_relay_struct(i).capacity_fuzzymeans_bps = ((TBS1.BW_Hz * length(find(uav_vessel_assignments_fcm == i))) / tbs_virtual_total_vessels_serve_fcm{1})*log2(1 + uavs_relay_struct(i).max_SNR_fuzzy_means_pure);
        uavs_relay_struct(i).capacity_fuzzymeans_Mbps = uavs_relay_struct(i).capacity_fuzzymeans_bps / 1e6;
    elseif uavs_relay_struct(i).index_SNR_fuzzymeans_TBS == 2
        uavs_relay_struct(i).capacity_fuzzymeans_bps = ((TBS2.BW_Hz * length(find(uav_vessel_assignments_fcm == i))) / tbs_virtual_total_vessels_serve_fcm{2})*log2(1 + uavs_relay_struct(i).max_SNR_fuzzy_means_pure);
        uavs_relay_struct(i).capacity_fuzzymeans_Mbps = uavs_relay_struct(i).capacity_fuzzymeans_bps / 1e6;
    elseif uavs_relay_struct(i).index_SNR_fuzzymeans_TBS == 3
        uavs_relay_struct(i).capacity_fuzzymeans_bps = ((TBS3.BW_Hz * length(find(uav_vessel_assignments_fcm == i))) / tbs_virtual_total_vessels_serve_fcm{3})*log2(1 + uavs_relay_struct(i).max_SNR_fuzzy_means_pure);
        uavs_relay_struct(i).capacity_fuzzymeans_Mbps = uavs_relay_struct(i).capacity_fuzzymeans_bps / 1e6;
    end
end
% 7th Step
% ---------------------------------------------------------------
% We already have a struct for all the vessels UE (inside and outside hotposts)
% struct ====>> total_vessel_ue_in_out_hotspots
% And now, we have struct also for ABSs, struct =====>> uavs_relay_struct
% So now we compute metrics from ABS to Vessels (2nd Tier)
for i = 1 : uav_N
    % --------
    % KMeans
    % --------
    % Find vessels assigned to current (i) ABS
    % ------------------------------------------------------
    vessel_indices = find(uav_vessel_assignments_kmeans == i);
    % For loop for all vessels current UAV servers
    % ------------------------------------------------------
    for j = 1 : length(vessel_indices)
        vessel_idx = vessel_indices(j); % Get vessel index
        % ------------------------------------------------------------------------------------------------------
        % a. Calculate distance between current serving ABS and jth Vessel.
        total_vessel_ue_in_out_hotspots(vessel_idx).distance_from_serving_ABS_kmeans_m = pdist([uavs_placement_data_kmeans(i).x, uavs_placement_data_kmeans(i).y, uavs_placement_data_kmeans(i).z; ...
            total_vessel_ue_in_out_hotspots(vessel_idx).x, total_vessel_ue_in_out_hotspots(vessel_idx).y, 0]);
        % ------------------------------------------------------------------------------------------------------
        % b. Calculate PL between current serving ABS and jth Vessel.
        total_vessel_ue_in_out_hotspots(vessel_idx).path_loss_from_serving_ABS_kmeans_dB = A2G_pl(total_vessel_ue_in_out_hotspots(vessel_idx).distance_from_serving_ABS_kmeans_m, abs_height_m, abs_fc_Hz);
        total_vessel_ue_in_out_hotspots(vessel_idx).path_loss_from_serving_ABS_kmeans_pure = 10^(total_vessel_ue_in_out_hotspots(vessel_idx).path_loss_from_serving_ABS_kmeans_dB/10);
        % ------------------------------------------------------------------------------------------------------
        % c. Calculate Rayleigh coefficient parameter
        % Rayleigh Fading Coefficients with Zero Mean and Variance 1
        total_vessel_ue_in_out_hotspots(vessel_idx).fading_from_serving_ABS_kmeans = Rayleigh_fading_coefficients();
        % ------------------------------------------------------------------------------------------------------
        % d. Calculate Channel Gain
        total_vessel_ue_in_out_hotspots(vessel_idx).channel_gain_from_serving_ABS_kmeans = abs(total_vessel_ue_in_out_hotspots(vessel_idx).fading_from_serving_ABS_kmeans)^2;
        % ------------------------------------------------------------------------------------------------------
        % e. Calculate Power received for serving ABS and only (Pr).
        total_vessel_ue_in_out_hotspots(vessel_idx).Pr_from_serving_ABS_kmeans_Watt = (abs_Pt_Watt * total_vessel_ue_in_out_hotspots(vessel_idx).channel_gain_from_serving_ABS_kmeans)/ total_vessel_ue_in_out_hotspots(vessel_idx).path_loss_from_serving_ABS_kmeans_pure;
        % HOWEVER, BEFORE WE FIND THE SINR, DUE TO INTERFERENCE WE MUST
        % CALCULATE ALL THE OTHER Pr from the uav_N - 1
        % ------------------------------------------------------------------------------------------------------
        % f. Calculate uav_N - 1 Pr from all the remaing ABSs
        % Compute interference from other ABSs
        Interference = 0;
        for k = 1:uav_N
            if k ~= i  % Exclude serving ABS (i-th)
                total_vessel_ue_in_out_hotspots(vessel_idx).distance_from_other_ABS_kmeans_m = pdist([uavs_placement_data_kmeans(k).x, uavs_placement_data_kmeans(k).y, uavs_placement_data_kmeans(k).z; ...
                    total_vessel_ue_in_out_hotspots(vessel_idx).x, total_vessel_ue_in_out_hotspots(vessel_idx).y, 0]);

                total_vessel_ue_in_out_hotspots(vessel_idx).path_loss_from_other_ABS_kmeans_dB = A2G_pl(total_vessel_ue_in_out_hotspots(vessel_idx).distance_from_other_ABS_kmeans_m, abs_height_m, abs_fc_Hz);
                total_vessel_ue_in_out_hotspots(vessel_idx).path_loss_from_other_ABS_kmeans_pure = 10^(total_vessel_ue_in_out_hotspots(vessel_idx).path_loss_from_other_ABS_kmeans_dB/10);

                total_vessel_ue_in_out_hotspots(vessel_idx).fading_from_other_ABS_kmeans = Rayleigh_fading_coefficients();

                total_vessel_ue_in_out_hotspots(vessel_idx).channel_gain_from_other_ABS_kmeans = abs(total_vessel_ue_in_out_hotspots(vessel_idx).fading_from_other_ABS_kmeans)^2;

                total_vessel_ue_in_out_hotspots(vessel_idx).Pr_from_other_ABS_kmeans_Watt = (abs_Pt_Watt *  total_vessel_ue_in_out_hotspots(vessel_idx).channel_gain_from_other_ABS_kmeans)/ total_vessel_ue_in_out_hotspots(vessel_idx).path_loss_from_other_ABS_kmeans_pure;

                Interference = Interference + total_vessel_ue_in_out_hotspots(vessel_idx).Pr_from_other_ABS_kmeans_Watt;
            end
        end
        % ------------------------------------------------------------------------------------------------------
        % g. Return back to the SINR of the j-th Vessel
        total_vessel_ue_in_out_hotspots(vessel_idx).SINR_from_serving_ABS_kmeans_pure = total_vessel_ue_in_out_hotspots(vessel_idx).Pr_from_serving_ABS_kmeans_Watt / ( Interference + (noise_Watt_Hz * abs_BW_Hz));
        % ------------------------------------------------------------------------------------------------------
        % h. Calculate Shannon Capacity DL for the j-th Vessel from the
        % serving ABS
        total_vessel_ue_in_out_hotspots(vessel_idx).capacity_from_serving_ABS_kmeans_bps = (abs_BW_Hz)*log2(1 + total_vessel_ue_in_out_hotspots(vessel_idx).SINR_from_serving_ABS_kmeans_pure);
        % ------------------------------------------------------------------------------------------------------
        % i. Now, we have the serving i-th ABS -> Vessel DL Capacity
        % We must retrieve the TBS -> ABS i-th DL Capacity and take the min of
        % them.
        total_vessel_ue_in_out_hotspots(vessel_idx).final_capacity_downlink_kmeans_bps = min([uavs_relay_struct(i).capacity_kmeans_bps, total_vessel_ue_in_out_hotspots(vessel_idx).capacity_from_serving_ABS_kmeans_bps]);
        total_vessel_ue_in_out_hotspots(vessel_idx).final_capacity_downlink_kmeans_Mbps = total_vessel_ue_in_out_hotspots(vessel_idx).final_capacity_downlink_kmeans_bps / 1e6;
    end
    % --------
    % KMedoids
    % --------
    % Find vessels assigned to current (i) ABS
    % ------------------------------------------------------
    vessel_indices = find(uav_vessel_assignments_kmedoids == i);
    % For loop for all vessels current UAV servers
    % ------------------------------------------------------
    for j = 1 : length(vessel_indices)
        vessel_idx = vessel_indices(j); % Get vessel index
        % ------------------------------------------------------------------------------------------------------
        % a. Calculate distance between vessel and ABSs.
        total_vessel_ue_in_out_hotspots(vessel_idx).distance_from_serving_ABS_kmedoids_m = pdist([uavs_placement_data_kmedoids(i).x, uavs_placement_data_kmedoids(i).y, uavs_placement_data_kmedoids(i).z; ...
            total_vessel_ue_in_out_hotspots(vessel_idx).x, total_vessel_ue_in_out_hotspots(vessel_idx).y, 0]);
        % ------------------------------------------------------------------------------------------------------
        % b. Calculate PL between current serving ABS and jth Vessel.
        total_vessel_ue_in_out_hotspots(vessel_idx).path_loss_from_serving_ABS_kmedoids_dB = A2G_pl(total_vessel_ue_in_out_hotspots(vessel_idx).distance_from_serving_ABS_kmedoids_m, abs_height_m, abs_fc_Hz);
        total_vessel_ue_in_out_hotspots(vessel_idx).path_loss_from_serving_ABS_kmedoids_pure = 10^(total_vessel_ue_in_out_hotspots(vessel_idx).path_loss_from_serving_ABS_kmedoids_dB/10);
        % ------------------------------------------------------------------------------------------------------
        % c. Calculate Rayleigh coefficient parameter
        % Rayleigh Fading Coefficients with Zero Mean and Variance 1
        total_vessel_ue_in_out_hotspots(vessel_idx).fading_from_serving_ABS_kmedoids = Rayleigh_fading_coefficients();
        % ------------------------------------------------------------------------------------------------------
        % d. Calculate Channel Gain
        total_vessel_ue_in_out_hotspots(vessel_idx).channel_gain_from_serving_ABS_kmedoids = abs(total_vessel_ue_in_out_hotspots(vessel_idx).fading_from_serving_ABS_kmedoids)^2;
        % ------------------------------------------------------------------------------------------------------
        % e. Calculate Power received for serving ABS and only (Pr).
        total_vessel_ue_in_out_hotspots(vessel_idx).Pr_from_serving_ABS_kmedoids_Watt = (abs_Pt_Watt * total_vessel_ue_in_out_hotspots(vessel_idx).channel_gain_from_serving_ABS_kmedoids)/ total_vessel_ue_in_out_hotspots(vessel_idx).path_loss_from_serving_ABS_kmedoids_pure;
        % HOWEVER, BEFORE WE FIND THE SINR, DUE TO INTERFERENCE WE MUST
        % CALCULATE ALL THE OTHER Pr from the uav_N - 1
        % ------------------------------------------------------------------------------------------------------
        % f. Calculate uav_N - 1 Pr from all the remaing ABSs
        % Compute interference from other ABSs
        Interference = 0;
        for k = 1:uav_N
            if k ~= i  % Exclude serving ABS (i-th)
                total_vessel_ue_in_out_hotspots(vessel_idx).distance_from_other_ABS_kmedoids_m = pdist([uavs_placement_data_kmedoids(k).x, uavs_placement_data_kmedoids(k).y, uavs_placement_data_kmedoids(k).z; ...
                    total_vessel_ue_in_out_hotspots(vessel_idx).x, total_vessel_ue_in_out_hotspots(vessel_idx).y, 0]);

                total_vessel_ue_in_out_hotspots(vessel_idx).path_loss_from_other_ABS_kmedoids_dB = A2G_pl(total_vessel_ue_in_out_hotspots(vessel_idx).distance_from_other_ABS_kmedoids_m, abs_height_m, abs_fc_Hz);
                total_vessel_ue_in_out_hotspots(vessel_idx).path_loss_from_other_ABS_kmedoids_pure = 10^(total_vessel_ue_in_out_hotspots(vessel_idx).path_loss_from_other_ABS_kmedoids_dB/10);

                total_vessel_ue_in_out_hotspots(vessel_idx).fading_from_other_ABS_kmedoids = Rayleigh_fading_coefficients();

                total_vessel_ue_in_out_hotspots(vessel_idx).channel_gain_from_other_ABS_kmedoids = abs(total_vessel_ue_in_out_hotspots(vessel_idx).fading_from_other_ABS_kmedoids)^2;

                total_vessel_ue_in_out_hotspots(vessel_idx).Pr_from_other_ABS_kmedoids_Watt = (abs_Pt_Watt * total_vessel_ue_in_out_hotspots(vessel_idx).channel_gain_from_other_ABS_kmedoids)/ total_vessel_ue_in_out_hotspots(vessel_idx).path_loss_from_other_ABS_kmedoids_pure;

                Interference = Interference + total_vessel_ue_in_out_hotspots(vessel_idx).Pr_from_other_ABS_kmedoids_Watt;
            end
        end
        % ------------------------------------------------------------------------------------------------------
        % g. Return back to the SINR of the j-th Vessel
        total_vessel_ue_in_out_hotspots(vessel_idx).SINR_from_serving_ABS_kmedoids_pure = total_vessel_ue_in_out_hotspots(vessel_idx).Pr_from_serving_ABS_kmedoids_Watt / ( Interference + (noise_Watt_Hz * abs_BW_Hz));
        % ------------------------------------------------------------------------------------------------------
        % h. Calculate Shannon Capacity DL for the j-th Vessel from the
        % serving ABS
        total_vessel_ue_in_out_hotspots(vessel_idx).capacity_from_serving_ABS_kmedoids_bps = (abs_BW_Hz)*log2(1 + total_vessel_ue_in_out_hotspots(vessel_idx).SINR_from_serving_ABS_kmedoids_pure);
        % ------------------------------------------------------------------------------------------------------
        % i. Now, we have the serving i-th ABS -> Vessel DL Capacity
        % We must retrieve the TBS -> ABS i-th DL Capacity and take the min of
        % them.
        total_vessel_ue_in_out_hotspots(vessel_idx).final_capacity_downlink_kmedoids_bps = min([uavs_relay_struct(i).capacity_kmedoids_bps, total_vessel_ue_in_out_hotspots(vessel_idx).capacity_from_serving_ABS_kmedoids_bps]);
        total_vessel_ue_in_out_hotspots(vessel_idx).final_capacity_downlink_kmedoids_Mbps = total_vessel_ue_in_out_hotspots(vessel_idx).final_capacity_downlink_kmedoids_bps / 1e6;
    end
    % --------
    % Fuzzy C-Means
    % --------
    % Find vessels assigned to current (i) ABS
    % ------------------------------------------------------
    vessel_indices = find(uav_vessel_assignments_fcm == i);
    % For loop for all vessels current UAV servers
    % ------------------------------------------------------
    for j = 1 : length(vessel_indices)
        vessel_idx = vessel_indices(j); % Get vessel index
        % ------------------------------------------------------------------------------------------------------
        % a. Calculate distance between vessel and ABSs.
        total_vessel_ue_in_out_hotspots(vessel_idx).distance_from_serving_ABS_fuzzymeans_m = pdist([uavs_placement_data_fcm(i).x, uavs_placement_data_fcm(i).y, uavs_placement_data_fcm(i).z; ...
            total_vessel_ue_in_out_hotspots(vessel_idx).x, total_vessel_ue_in_out_hotspots(vessel_idx).y, 0]);
        % ------------------------------------------------------------------------------------------------------
        % b. Calculate PL between current serving ABS and jth Vessel.
        total_vessel_ue_in_out_hotspots(vessel_idx).path_loss_from_serving_ABS_fuzzymeans_dB = A2G_pl(total_vessel_ue_in_out_hotspots(vessel_idx).distance_from_serving_ABS_fuzzymeans_m, abs_height_m, abs_fc_Hz);
        total_vessel_ue_in_out_hotspots(vessel_idx).path_loss_from_serving_ABS_fuzzymeans_pure = 10^(total_vessel_ue_in_out_hotspots(vessel_idx).path_loss_from_serving_ABS_fuzzymeans_dB/10);
        % ------------------------------------------------------------------------------------------------------
        % c. Calculate Rayleigh coefficient parameter
        % Rayleigh Fading Coefficients with Zero Mean and Variance 1
        total_vessel_ue_in_out_hotspots(vessel_idx).fading_from_serving_ABS_fuzzymeans = Rayleigh_fading_coefficients();
        % ------------------------------------------------------------------------------------------------------
        % d. Calculate Channel Gain
        total_vessel_ue_in_out_hotspots(vessel_idx).channel_gain_from_serving_ABS_fuzzymeans = abs(total_vessel_ue_in_out_hotspots(vessel_idx).fading_from_serving_ABS_fuzzymeans)^2;
        % ------------------------------------------------------------------------------------------------------
        % e. Calculate Power received for serving ABS and only (Pr).
        total_vessel_ue_in_out_hotspots(vessel_idx).Pr_from_serving_ABS_fuzzymeans_Watt = (abs_Pt_Watt * total_vessel_ue_in_out_hotspots(vessel_idx).channel_gain_from_serving_ABS_fuzzymeans)/ total_vessel_ue_in_out_hotspots(vessel_idx).path_loss_from_serving_ABS_fuzzymeans_pure;
        % HOWEVER, BEFORE WE FIND THE SINR, DUE TO INTERFERENCE WE MUST
        % CALCULATE ALL THE OTHER Pr from the uav_N - 1
        % ------------------------------------------------------------------------------------------------------
        % f. Calculate uav_N - 1 Pr from all the remaing ABSs
        % Compute interference from other ABSs
        Interference = 0;
        for k = 1:uav_N
            if k ~= i  % Exclude serving ABS (i-th)
                total_vessel_ue_in_out_hotspots(vessel_idx).distance_from_other_ABS_fuzzymeans_m = pdist([uavs_placement_data_fcm(k).x, uavs_placement_data_fcm(k).y, uavs_placement_data_fcm(k).z; ...
                    total_vessel_ue_in_out_hotspots(vessel_idx).x, total_vessel_ue_in_out_hotspots(vessel_idx).y, 0]);

                total_vessel_ue_in_out_hotspots(vessel_idx).path_loss_from_other_ABS_fuzzymeans_dB = A2G_pl(total_vessel_ue_in_out_hotspots(vessel_idx).distance_from_other_ABS_fuzzymeans_m, abs_height_m, abs_fc_Hz);
                total_vessel_ue_in_out_hotspots(vessel_idx).path_loss_from_other_ABS_fuzzymeans_pure = 10^(total_vessel_ue_in_out_hotspots(vessel_idx).path_loss_from_other_ABS_fuzzymeans_dB/10);

                total_vessel_ue_in_out_hotspots(vessel_idx).fading_from_other_ABS_fuzzymeans = Rayleigh_fading_coefficients();

                total_vessel_ue_in_out_hotspots(vessel_idx).channel_gain_from_other_ABS_fuzzymeans = abs(total_vessel_ue_in_out_hotspots(vessel_idx).fading_from_other_ABS_fuzzymeans)^2;

                total_vessel_ue_in_out_hotspots(vessel_idx).Pr_from_other_ABS_fuzzymeans_Watt = (abs_Pt_Watt * total_vessel_ue_in_out_hotspots(vessel_idx).channel_gain_from_other_ABS_fuzzymeans)/ total_vessel_ue_in_out_hotspots(vessel_idx).path_loss_from_other_ABS_fuzzymeans_pure;

                Interference = Interference + total_vessel_ue_in_out_hotspots(vessel_idx).Pr_from_other_ABS_fuzzymeans_Watt;
            end
        end
        % ------------------------------------------------------------------------------------------------------
        % g. Return back to the SINR of the j-th Vessel
        total_vessel_ue_in_out_hotspots(vessel_idx).SINR_from_serving_ABS_fuzzymeans_pure = total_vessel_ue_in_out_hotspots(vessel_idx).Pr_from_serving_ABS_fuzzymeans_Watt / ( Interference + (noise_Watt_Hz * abs_BW_Hz));
        % ------------------------------------------------------------------------------------------------------
        % h. Calculate Shannon Capacity DL for the j-th Vessel from the
        % serving ABS
        total_vessel_ue_in_out_hotspots(vessel_idx).capacity_from_serving_ABS_fuzzymeans_bps = (abs_BW_Hz)*log2(1 + total_vessel_ue_in_out_hotspots(vessel_idx).SINR_from_serving_ABS_fuzzymeans_pure);
        % ------------------------------------------------------------------------------------------------------
        % i. Now, we have the serving i-th ABS -> Vessel DL Capacity
        % We must retrieve the TBS -> ABS i-th DL Capacity and take the min of
        % them.
        total_vessel_ue_in_out_hotspots(vessel_idx).final_capacity_downlink_fuzzymeans_bps = min([uavs_relay_struct(i).capacity_fuzzymeans_bps, total_vessel_ue_in_out_hotspots(vessel_idx).capacity_from_serving_ABS_fuzzymeans_bps]);
        total_vessel_ue_in_out_hotspots(vessel_idx).final_capacity_downlink_fuzzymeans_Mbps = total_vessel_ue_in_out_hotspots(vessel_idx).final_capacity_downlink_fuzzymeans_bps / 1e6;
    end
end
% ---------------------------------------------------------------
% Assign zero rate to vessels with no ABS association (i.e., association = 0)
% ---------------------------------------------------------------
for v = 1:length(total_vessel_ue_in_out_hotspots)
    if uav_vessel_assignments_kmeans(v) == 0
        total_vessel_ue_in_out_hotspots(v).final_capacity_downlink_kmeans_bps = 0;
        total_vessel_ue_in_out_hotspots(v).final_capacity_downlink_kmeans_Mbps = 0;
    end

    if uav_vessel_assignments_fcm(v) == 0
        total_vessel_ue_in_out_hotspots(v).final_capacity_downlink_fuzzymeans_bps = 0;
        total_vessel_ue_in_out_hotspots(v).final_capacity_downlink_fuzzymeans_Mbps = 0;
    end

    if uav_vessel_assignments_kmedoids(v) == 0
        total_vessel_ue_in_out_hotspots(v).final_capacity_downlink_kmedoids_bps = 0;
        total_vessel_ue_in_out_hotspots(v).final_capacity_downlink_kmedoids_Mbps = 0;
    end
end
end


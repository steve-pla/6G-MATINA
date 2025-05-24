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
function [total_vessel_ue_in_out_hotspots] = network_with_no_uav_runner(total_vessel_ue_in_out_hotspots, total_vessels_N,...
    tbs_height_m, TBS1, TBS2, TBS3, noise_Watt_Hz, maritime_loss_dB, sea_attenuation_dB,...
    vessel_antenna_height_m, reference_distance_tbs_vessel_m)
% For loop to calculate distance ---> path_loss ---> fadings ---> SNR (No
% Interference here!!) ---> Cacapacity!
% In this function, we have no ABS deployed.
% It is the basic scenario which will be the worst.
% To hold for each TBS which Vessel is serving, create a temp 2d array
tbs_vessels_association_array = zeros(5,2);  % Preallocate space for efficiency
% Start calculations for all Vessels
for i = 1 : total_vessels_N
    % ------------------------------------------------------------------------------------------------------
    % a. Calculate distance between TBSs and each Vessel.
    total_vessel_ue_in_out_hotspots(i).distance_tbs1_vessel_m = pdist([total_vessel_ue_in_out_hotspots(i).x, total_vessel_ue_in_out_hotspots(i).y, 0; TBS1.x, TBS1.y, TBS1.z]);
    total_vessel_ue_in_out_hotspots(i).distance_tbs2_vessel_m = pdist([total_vessel_ue_in_out_hotspots(i).x, total_vessel_ue_in_out_hotspots(i).y, 0; TBS2.x, TBS2.y, TBS2.z]);
    total_vessel_ue_in_out_hotspots(i).distance_tbs3_vessel_m = pdist([total_vessel_ue_in_out_hotspots(i).x, total_vessel_ue_in_out_hotspots(i).y, 0; TBS3.x, TBS3.y, TBS3.z]);
    % ------------------------------------------------------------------------------------------------------
    % b. Calculate PL between TBSs and each Vessel.
    total_vessel_ue_in_out_hotspots(i).path_loss_tbs1_vessel_dB = ITU_P1812_5_pl(total_vessel_ue_in_out_hotspots(i).distance_tbs1_vessel_m, TBS1.Fc_Hz, tbs_height_m, vessel_antenna_height_m, ...
        reference_distance_tbs_vessel_m, maritime_loss_dB, sea_attenuation_dB);
    total_vessel_ue_in_out_hotspots(i).path_loss_tbs1_vessel_pure = 10^(total_vessel_ue_in_out_hotspots(i).path_loss_tbs1_vessel_dB/10);
    total_vessel_ue_in_out_hotspots(i).path_loss_tbs2_vessel_dB = ITU_P1812_5_pl(total_vessel_ue_in_out_hotspots(i).distance_tbs2_vessel_m, TBS2.Fc_Hz, tbs_height_m, vessel_antenna_height_m, ...
        reference_distance_tbs_vessel_m, maritime_loss_dB, sea_attenuation_dB);
    total_vessel_ue_in_out_hotspots(i).path_loss_tbs2_vessel_pure = 10^(total_vessel_ue_in_out_hotspots(i).path_loss_tbs2_vessel_dB/10);
    total_vessel_ue_in_out_hotspots(i).path_loss_tbs3_vessel_dB = ITU_P1812_5_pl(total_vessel_ue_in_out_hotspots(i).distance_tbs3_vessel_m, TBS3.Fc_Hz, tbs_height_m, vessel_antenna_height_m, ...
        reference_distance_tbs_vessel_m, maritime_loss_dB, sea_attenuation_dB);
    total_vessel_ue_in_out_hotspots(i).path_loss_tbs3_vessel_pure = 10^(total_vessel_ue_in_out_hotspots(i).path_loss_tbs3_vessel_dB/10);
    % ------------------------------------------------------------------------------------------------------
    % c. Calculate Rayleigh coefficient parameter
    % Rayleigh Fading Coefficients with Zero Mean and Variance 1
    total_vessel_ue_in_out_hotspots(i).fading_tbs1_vessel = Rayleigh_fading_coefficients();
    total_vessel_ue_in_out_hotspots(i).fading_tbs2_vessel = Rayleigh_fading_coefficients();
    total_vessel_ue_in_out_hotspots(i).fading_tbs3_vessel = Rayleigh_fading_coefficients();
    % ------------------------------------------------------------------------------------------------------
    % d. Calculate Channel Gain
    total_vessel_ue_in_out_hotspots(i).channel_gain_tbs1_vessel = abs(total_vessel_ue_in_out_hotspots(i).fading_tbs1_vessel)^2;
    total_vessel_ue_in_out_hotspots(i).channel_gain_tbs2_vessel = abs(total_vessel_ue_in_out_hotspots(i).fading_tbs2_vessel)^2;
    total_vessel_ue_in_out_hotspots(i).channel_gain_tbs3_vessel = abs(total_vessel_ue_in_out_hotspots(i).fading_tbs3_vessel)^2;
    % ------------------------------------------------------------------------------------------------------
    % e. Calculate Power received for each Vessel from 3 TBSs (Pr).
    total_vessel_ue_in_out_hotspots(i).Pr_tbs1_vessel_Watt = (TBS1.Pt_Watt * total_vessel_ue_in_out_hotspots(i).channel_gain_tbs1_vessel) / total_vessel_ue_in_out_hotspots(i).path_loss_tbs1_vessel_pure;
    total_vessel_ue_in_out_hotspots(i).Pr_tbs2_vessel_Watt = (TBS2.Pt_Watt * total_vessel_ue_in_out_hotspots(i).channel_gain_tbs2_vessel)/ total_vessel_ue_in_out_hotspots(i).path_loss_tbs2_vessel_pure;
    total_vessel_ue_in_out_hotspots(i).Pr_tbs3_vessel_Watt = (TBS3.Pt_Watt * total_vessel_ue_in_out_hotspots(i).channel_gain_tbs3_vessel)/ total_vessel_ue_in_out_hotspots(i).path_loss_tbs3_vessel_pure;
    % ------------------------------------------------------------------------------------------------------
    % f. Calculate SNR between TBSs and Vessel.
    total_vessel_ue_in_out_hotspots(i).SNR_tbs1_vessel_pure = total_vessel_ue_in_out_hotspots(i).Pr_tbs1_vessel_Watt / (noise_Watt_Hz * TBS1.BW_Hz);
    total_vessel_ue_in_out_hotspots(i).SNR_tbs2_vessel_pure = total_vessel_ue_in_out_hotspots(i).Pr_tbs2_vessel_Watt / (noise_Watt_Hz * TBS2.BW_Hz);
    total_vessel_ue_in_out_hotspots(i).SNR_tbs3_vessel_pure = total_vessel_ue_in_out_hotspots(i).Pr_tbs3_vessel_Watt / (noise_Watt_Hz * TBS3.BW_Hz);
    % ------------------------------------------------------------------------------------------------------
    % g. Selection Algorithm. Each Vessel must choose 1 of 3 TBSs for DL
    % transmission. Select the TBS with the max SNR.
    % So, we have 1 max SNR.
    [total_vessel_ue_in_out_hotspots(i).max_SNR_tbs_vessel_pure, total_vessel_ue_in_out_hotspots(i).index_max_SNR_tbs_vessel] = max([total_vessel_ue_in_out_hotspots(i).SNR_tbs1_vessel_pure, ...
        total_vessel_ue_in_out_hotspots(i).SNR_tbs2_vessel_pure, total_vessel_ue_in_out_hotspots(i).SNR_tbs3_vessel_pure]);
    % We need to count how many vessels each TBS served to calculate
    % Capacity.
    % Hold the association.
    tbs_vessels_association_array(i, 1) = i;
    tbs_vessels_association_array(i, 2) = total_vessel_ue_in_out_hotspots(i).index_max_SNR_tbs_vessel;
end
% ---------------------------------------------------------------
% We must collect statistics for each ML model -> how many ABS each TBS is
% serving!
tbs_1_serving_vessels = sum(tbs_vessels_association_array(:, 2) == 1);
tbs_2_serving_vessels = sum(tbs_vessels_association_array(:, 2) == 2);
tbs_3_serving_vessels = sum(tbs_vessels_association_array(:, 2) == 3);
% ---------------------------------------------------------------
% We now can calculate Shannon Capacity for each ABS knowing the spectrum.
for i = 1 : total_vessels_N
    if total_vessel_ue_in_out_hotspots(i).index_max_SNR_tbs_vessel == 1
        total_vessel_ue_in_out_hotspots(i).capacity_vessel_bps = (TBS1.BW_Hz / tbs_1_serving_vessels)*log2(1 + total_vessel_ue_in_out_hotspots(i).max_SNR_tbs_vessel_pure);
        total_vessel_ue_in_out_hotspots(i).capacity_vessel_Mbps = total_vessel_ue_in_out_hotspots(i).capacity_vessel_bps / 1e6;
    elseif total_vessel_ue_in_out_hotspots(i).index_max_SNR_tbs_vessel == 2
        total_vessel_ue_in_out_hotspots(i).capacity_vessel_bps = (TBS2.BW_Hz / tbs_2_serving_vessels)*log2(1 + total_vessel_ue_in_out_hotspots(i).max_SNR_tbs_vessel_pure);
        total_vessel_ue_in_out_hotspots(i).capacity_vessel_Mbps = total_vessel_ue_in_out_hotspots(i).capacity_vessel_bps / 1e6;
    elseif total_vessel_ue_in_out_hotspots(i).index_max_SNR_tbs_vessel == 3
        total_vessel_ue_in_out_hotspots(i).capacity_vessel_bps = (TBS3.BW_Hz / tbs_3_serving_vessels)*log2(1 + total_vessel_ue_in_out_hotspots(i).max_SNR_tbs_vessel_pure);
        total_vessel_ue_in_out_hotspots(i).capacity_vessel_Mbps = total_vessel_ue_in_out_hotspots(i).capacity_vessel_bps / 1e6;
    end
end
end


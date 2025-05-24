%% 6G-MATINA Simulator
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
%% Simulation Configuration 
% --------------------------
%% Monte Carlo Simulation
monte_carlo_iterations_N_conf = 1; % How many times simulation will run.
%% Simulation 2x2 square area
area_min_m_conf = -2000; % Minimum coordinate for the square area (m).
area_max_m_conf = 2000;  % Maximum coordinate for the square area (m).
%% Total No.# of Vessels in the simulation area
total_vessels_N_conf = 50;    % Total number of vessels inside and outside hotspots.
%% Total No.# of vessel hotsposts.
vessel_hotspots_N_conf = 5;  % Number of vessel hotspots.
% We create actually uav_hotspot (x,y) centers inside the area, where Vessels gonna
% reside.
vessel_hotspots_radius_m_conf = 35; % Radius of each vessel hotspots (m)
% Poisson Distribution parameters
lambda_N_vessels_conf = 10; % Mean number of vessels per vessel_hotspots
%% Pure UAV/ABS number
uav_N_conf = 10; % This means, that this number is the number of UAVs that will be deployed as ABSs.
% Or, we can refer to it as number of clusters.
%% Aerial Base Station (ABSs) Properties
% All ABS we consider transmit DL at the same fc
abs_fc_Hz_conf = 4e9; %(Hz -> 4 GHz)
% Static/Fixed ABS/UAV Height
abs_height_m_conf = 1200; %(m)
% Power Transmission 
abs_Pt_dBm_conf = 40; %(dBm)
abs_Pt_Watt_conf = 10^((abs_Pt_dBm_conf - 30)/10); %(Watt)
% Spectum of ABS
abs_BW_Hz_conf = 1000e6; % (Hz -> 100 MHz)
% ABS Cluster Max Vessels Limit
abs_cluster_vessels_limit_N_conf = 10; % Number of vessels can serve
%% Terrestrial Base Stations (TBSs) Properties
% We know that we support exactly 3 TBSs. So, we have 3 BWs, and 3 fcs for each one.
tbs_1_BW_Hz_conf = 100e6; % (Hz -> 100 MHz)
tbs_1_Fc_Hz_conf = 3.5e9; % (Hz -> 3.5 GHz)
tbs_2_BW_Hz_conf = 80e6; % (Hz -> 80M Hz)
tbs_2_Fc_Hz_conf = 2.6e9; % (Hz -> 2.6 GHz)
tbs_3_BW_Hz_conf = 60e6; % (Hz -> 60 MHz)
tbs_3_Fc_Hz_conf = 1.8e9; % (Hz -> 1.8 GHz)
% Static/Fixed TBS Height
tbs_height_m_conf = 60; %(m)
% Power Transmission (dBm)
tbs_1_Pt_dBm_conf = 40; %(dBm)
tbs_2_Pt_dBm_conf = 40; %(dBm)
tbs_3_Pt_dBm_conf = 40; %(dBm)
tbs_1_Pt_Watt_conf = 10^((tbs_1_Pt_dBm_conf - 30)/10); %(Watt)
tbs_2_Pt_Watt_conf = 10^((tbs_2_Pt_dBm_conf - 30)/10); %(Watt)
tbs_3_Pt_Watt_conf = 10^((tbs_3_Pt_dBm_conf - 30)/10); %(Watt)
%% Noise Power Density
noise_dBm_Hz_conf = -174; %(dBm/Hz)
noise_Watt_Hz_conf = 10^((noise_dBm_Hz_conf - 30) / 10); % (Watt/Hz)
%% ITU Path Loss Parameters
maritime_loss_dB_conf = 0; %(dB)
sea_attenuation_dB_conf = 0; %(dB)
vessel_antenna_height_m_conf = 5; %(m)
reference_distance_tbs_vessel_m_conf = 10; %(m)

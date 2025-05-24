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
function [TBS1, TBS2, TBS3, total_vessel_ue_in_out_hotspots, vessel_hotspots, ...
    vessel_ue_in_hotspots, vessel_ue_out_hotspots, number_of_vessels_ue_out_hotspots,...
    number_of_vessels_ue_in_hotspots] = topology_initializer(area_min, area_max, ...
    total_number_of_vessels, N_vessel_hotspots, Lambda, Vessel_hotspots_radius_m, ...
    TBS_1_BW, TBS_1_Fc, TBS_1_Pt_dBm, TBS_2_BW, TBS_2_Fc, TBS_2_Pt_dBm, TBS_3_BW,...
    TBS_3_Fc, TBS_3_Pt_dBm, tbs_height, TBS_1_Pt_Watt, TBS_2_Pt_Watt, TBS_3_Pt_Watt)
% Define the area as a struct of area_min, area_max
% ------------------------------------------------
% Define TBS positions as structs
TBS1 = struct('name', 'Upper Right', 'position', [area_max, area_max]);
TBS2 = struct('name', 'Upper Left', 'position', [area_min, area_max]);
TBS3 = struct('name', 'Bottom Center', 'position', [0, area_min]);
% Add x, y, and z coordinates fields to each TBS
% -----------------------------------------------
TBS1.x = TBS1.position(1); % x coordinate
TBS1.y = TBS1.position(2); % y coordinate
TBS1.z = tbs_height;       % z coordinate
% -----------------
TBS2.x = TBS2.position(1); % x coordinate
TBS2.y = TBS2.position(2); % y coordinate
TBS2.z = tbs_height;       % z coordinate
% -----------------
TBS3.x = TBS3.position(1); % x coordinate
TBS3.y = TBS3.position(2); % y coordinate
TBS3.z = tbs_height;       % z coordinate
% Assign Spectrum properties to TBSs
% ----------------------------------
TBS1.BW_Hz = TBS_1_BW;
TBS1.Fc_Hz = TBS_1_Fc;
TBS2.BW_Hz = TBS_2_BW;
TBS2.Fc_Hz = TBS_2_Fc;
TBS3.BW_Hz = TBS_3_BW;
TBS3.Fc_Hz = TBS_3_Fc;
% Assign Power Transmissions to TBSs
% ----------------------------------
TBS1.Pt_dBm = TBS_1_Pt_dBm;
TBS2.Pt_dBm = TBS_2_Pt_dBm;
TBS3.Pt_dBm = TBS_3_Pt_dBm;
TBS1.Pt_Watt = TBS_1_Pt_Watt;
TBS2.Pt_Watt = TBS_2_Pt_Watt;
TBS3.Pt_Watt = TBS_3_Pt_Watt;
% Generate hotspots centers (x,y) randomly in the area
% ---------------------------------------------------
vessel_hotspots = struct('x', [], 'y', []);
for i = 1:N_vessel_hotspots
    x = (area_max - area_min) * rand + area_min; % Random x-coordinate
    y = (area_max - area_min) * rand + area_min; % Random y-coordinate
    vessel_hotspots(i).id = i;    
    vessel_hotspots(i).x = x;
    vessel_hotspots(i).y = y;
end
% ------------
id_counter = 1; % Start ID from 1
% ------------
% Generate vessels in vessel hotspots with Poisson-distributed numbers
% -------------------------------------------------------------------
vessel_ue_in_hotspots = struct([]);
number_of_vessels_ue_in_hotspots = 0; % Counter for total vessels
for i = 1:N_vessel_hotspots
    statistical_number_of_vessels = poissrnd(Lambda); % Generate number of vessels for this hotspot
    number_of_vessels_ue_in_hotspots = number_of_vessels_ue_in_hotspots + statistical_number_of_vessels;
    for j = 1:statistical_number_of_vessels
        angle = 2 * pi * rand; % Random angle
        radius = Vessel_hotspots_radius_m * sqrt(rand); % Random distance within the radius
        x = vessel_hotspots(i).x + radius * cos(angle);
        y = vessel_hotspots(i).y + radius * sin(angle);
        vessel_ue_in_hotspots(end + 1).id = id_counter; %#ok<SAGROW>
        vessel_ue_in_hotspots(end).x = x;
        vessel_ue_in_hotspots(end).y = y;
        vessel_ue_in_hotspots(end).hotspot_id = vessel_hotspots(i).id; % Store the hotspot ID
        id_counter = id_counter + 1; % Increment vessel ID
    end
end
% Remaining vessels distributed in the general area
% -------------------------------------------------
number_of_vessels_ue_out_hotspots = total_number_of_vessels - number_of_vessels_ue_in_hotspots;
vessel_ue_out_hotspots = struct([]);
for i = 1:number_of_vessels_ue_out_hotspots
    x = (area_max - area_min) * rand + area_min;
    y = (area_max - area_min) * rand + area_min;
    vessel_ue_out_hotspots(end + 1).id = id_counter; %#ok<SAGROW>
    vessel_ue_out_hotspots(end).x = x;
    vessel_ue_out_hotspots(end).y = y;
    vessel_ue_out_hotspots(end).tag = "outer area"; % Tag as outside a hotspot
    id_counter = id_counter + 1; % Increment vessel ID
end
% Concatenate vessels inside hotspots and outside into a single struct
% -------------------------------------------------
total_vessel_ue_in_out_hotspots = struct([]);
% Add vessels inside hotspots
% -------------------------------------------------
for i = 1:length(vessel_ue_in_hotspots)
    total_vessel_ue_in_out_hotspots(i).id = vessel_ue_in_hotspots(i).id;
    total_vessel_ue_in_out_hotspots(i).x = vessel_ue_in_hotspots(i).x;
    total_vessel_ue_in_out_hotspots(i).y = vessel_ue_in_hotspots(i).y;
    total_vessel_ue_in_out_hotspots(i).tag = "Inside Hotspot ID: " + string(vessel_ue_in_hotspots(i).hotspot_id);
end
% Add vessels outside hotspots
% -------------------------------------------------
offset = length(vessel_ue_in_hotspots);
for i = 1:length(vessel_ue_out_hotspots)
    total_vessel_ue_in_out_hotspots(offset + i).id = vessel_ue_out_hotspots(i).id;
    total_vessel_ue_in_out_hotspots(offset + i).x = vessel_ue_out_hotspots(i).x;
    total_vessel_ue_in_out_hotspots(offset + i).y = vessel_ue_out_hotspots(i).y;
    total_vessel_ue_in_out_hotspots(offset + i).tag = "outer area";
end
end







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
function [] = topology_with_vessels_uavs_ploter(area_min, area_max, TBS1, TBS2, TBS3,...
    vessel_hotspots, vessel_hotspots_radius, vessel_hotspots_UEs, outer_vessel_UEs,...
    N_abs, ABS_placement_data_fuzzymeans, ...
    ABS_placement_data_Kmeans, ABS_placement_data_kmedoids, abs_relay_struct)





area_min_m_conf, area_max_m_conf, TBS1, TBS2, TBS3,...
    vessel_hotspots, vessel_hotspots_radius_m_conf, vessel_ue_in_hotspots,...
    vessel_ue_out_hotspots, uav_N_conf, uavs_placement_data_fcm, ...
    uavs_placement_data_kmeans, uavs_placement_data_kmedoids, uavs_relay_struct




%BASIC_PLOTER Summary of this function goes here

figure;
hold on;
axis equal;
xlim([area_min, area_max]);
ylim([area_min, area_max]);

% Plot TBS locations using red triangle markers
h1 = scatter(TBS1.position(1), TBS1.position(2), 200, '^', 'r', 'filled'); % TBS 1 (Red Triangle)
h2 = scatter(TBS2.position(1), TBS2.position(2), 200, '^', 'r', 'filled'); % TBS 2 (Red Triangle)
h3 = scatter(TBS3.position(1), TBS3.position(2), 200, '^', 'r', 'filled'); % TBS 3 (Red Triangle)

% Plot vessel hotspots (Pink Center + Radius)
h4 = []; % Initialize handle for hotspot centers
h5 = []; % Initialize handle for hotspot radii
for i = 1:length(vessel_hotspots)
    h4 = scatter(vessel_hotspots(i).x, vessel_hotspots(i).y, 150, 'm', 'filled'); % Hotspot Center (Pink)
    h5 = viscircles([vessel_hotspots(i).x, vessel_hotspots(i).y], vessel_hotspots_radius, 'Color', 'm', 'LineWidth', 1); % Hotspot Radius (Pink Circle)
end

% Plot vessels inside hotspots (Green)
h6 = []; % Initialize handle for vessels in hotspots
for i = 1:length(vessel_hotspots_UEs)
    h6 = scatter(vessel_hotspots_UEs(i).x, vessel_hotspots_UEs(i).y, 30, 'g', 'filled'); % Vessel in Hotspot (Green)
end

% Plot vessels in the general area (Blue)
h7 = []; % Initialize handle for vessels outside hotspots
for i = 1:length(outer_vessel_UEs)
    h7 = scatter(outer_vessel_UEs(i).x, outer_vessel_UEs(i).y, 30, 'b', 'filled'); % Vessel Outside Hotspot (Blue)
end

% Plot ABS placements from ML models

% Plot ABS based on fuzzy (Black)
h8 = []; % Initialize handle for Fuzzy ABS
for i = 1:N_abs
    h8 = plot(ABS_placement_data_fuzzymeans(i).x, ABS_placement_data_fuzzymeans(i).y, 'k^', 'MarkerSize', 10, 'LineWidth', 2); % Fuzzy (Black)
end

% Plot ABS based on k-means (Orange)
h9 = []; % Initialize handle for K-Means ABS
for i = 1:N_abs
    h9 = plot(ABS_placement_data_Kmeans(i).x, ABS_placement_data_Kmeans(i).y, 'or', 'MarkerSize', 10, 'LineWidth', 2); % K-Means (Orange)
end

% Plot ABS based on k-medoids (Cyan)
h10 = []; % Initialize handle for K-Medoids ABS
for i = 1:N_abs
    h10 = plot(ABS_placement_data_kmedoids(i).x, ABS_placement_data_kmedoids(i).y, 'sc', 'MarkerSize', 10, 'LineWidth', 2); % K-Medoids (Cyan)
end

% Add labels and title
xlabel('X Coordinate (m)');
ylabel('Y Coordinate (m)');
title('Vessel Distribution in Maritime Area');

% Add legend with all handles and labels
legend([h1, h2, h3, h4, h6, h7, h9, h10, h8], ...
    {'TBS 1', 'TBS 2', 'TBS 3', 'Hotspot Center', 'Vessel in Hotspot', 'Vessel Outside Hotspot', ...
    'K-Means ABS', 'K-Medoids ABS', 'Fuzzy C-Means ABS'}, ...
    'Location', 'best');

grid on;
hold off;

% Define custom colors (simpler method)
bar_colors = [0 0.4470 0.7410;   % Blue (K-Means)
              0.8500 0.3250 0.0980;  % Red (K-Medoids)
              0.9290 0.6940 0.1250]; % Yellow (Fuzzy C-Means)

total_throughput = [sum([abs_relay_struct.capacity_kmeans_Mbps]), sum([abs_relay_struct.capacity_kmedoids_Mbps]), sum([abs_relay_struct.capacity_fuzzymeans_Mbps])];
% Create figure
figure;
hold on;
% Plot each bar separately to ensure individual colors & legend
for i = 1:3
    bars(i) = bar(i, total_throughput(i), 'FaceColor', bar_colors(i, :));
end
% Customize x-axis
set(gca, 'XTick', 1:3, 'XTickLabel', {'K-Means ABS', 'K-Medoids ABS', 'Fuzzy C-Means ABS'});
% Labels & title
xlabel('ML Model');
ylabel('Total System Throughput (Mbps)');
title('Total ABS Downlink System Throughput Comparison');
grid on;
% Add correct legend
legend(bars, {'K-Means', 'K-Medoids', 'Fuzzy C-Means'}, 'Location', 'Best');
hold off;

end


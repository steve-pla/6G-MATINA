clear all;
clc;

% Parameters
area_min = -2000; % Minimum coordinate for the square area
area_max = 2000;  % Maximum coordinate for the square area
N_users = 1500;    % Total number of users (input parameter)
uav_hotspot = 5;  % Number of UAV hotspots (input parameter)
uav_hotspot_radius = 100; % Radius of each UAV hotspot in meters (input parameter)
lambda = 10;      % Mean number of users per hotspot (Poisson parameter)
dHeight = 100;
clusters = 10;


[TBS1,TBS2,TBS3, UE, uav_hotspots,uav_users, general_users,total_uav_users,remaining_users] = ue_tbs_export(area_min,area_max,N_users,uav_hotspot,lambda,uav_hotspot_radius);


% Convert UE to a numerical array of coordinates *before* the loop
UE_coords = [UE.x; UE.y]';  % Efficient way to extract coordinates

DronesKmeans = drone('kmeans', UE,clusters, dHeight)
DronesKmedoids = drone('kmedoids', UE,clusters, dHeight)
DronesFuzzyMeans = drone('fuzzy', UE,clusters, dHeight)


% Visualization
figure;
hold on;
axis([area_min area_max area_min area_max]);
grid on;

% Plot the area boundaries
rectangle('Position', [area_min, area_min, area_max - area_min, area_max - area_min], 'EdgeColor', 'black');

% Plot TBS positions
plot(TBS1.position(1), TBS1.position(2), 'ro', 'MarkerSize', 10, 'DisplayName', 'TBS Upper Right');
plot(TBS2.position(1), TBS2.position(2), 'ro', 'MarkerSize', 10, 'DisplayName', 'TBS Upper Left');
plot(TBS3.position(1), TBS3.position(2), 'ro', 'MarkerSize', 10, 'DisplayName', 'TBS Bottom Center');


% Plot UAV based on k-means
for i = 1:clusters
    plot(DronesKmeans(i).x, DronesKmeans(i).y, 'ro', 'MarkerSize', 10, 'LineWidth', 2, 'DisplayName', 'K-means');
end

% Plot UAV based on k-medoids
for i = 1:clusters
    plot(DronesKmedoids(i).x, DronesKmedoids(i).y, 'bo', 'MarkerSize', 10, 'LineWidth', 2, 'DisplayName', 'K-medoids');
end

% Plot UAV based on fuzzy
for i = 1:clusters
    plot(DronesFuzzyMeans(i).x, DronesFuzzyMeans(i).y, 'yo', 'MarkerSize', 10, 'LineWidth', 2, 'DisplayName', 'Fuzzy');
end

% Plot UAV hotspots
for i = 1:uav_hotspot
    plot(uav_hotspots(i).x, uav_hotspots(i).y, 'bx', 'MarkerSize', 10, 'LineWidth', 2);
    viscircles([uav_hotspots(i).x, uav_hotspots(i).y], uav_hotspot_radius, 'LineStyle', '--', 'EdgeColor', 'b');
end



% Plot users in UAV hotspots
for i = 1:length(uav_users)
    plot(uav_users(i).x, uav_users(i).y, 'go', 'MarkerSize', 6);
end

% Plot remaining users in the general area
for i = 1:length(general_users)
    scatter(general_users(i).x, general_users(i).y, 'k.');
end

legend('show');
title('2D Area with TBSs, UAV Hotspots, and Users');
xlabel('X Coordinate (m)');
ylabel('Y Coordinate (m)');
hold off;

% Print user distribution summary
fprintf('Total Users: %d\n', N_users);
fprintf('Total Users in UAV Hotspots: %d\n', total_uav_users);
fprintf('Remaining Users in General Area: %d\n', remaining_users);




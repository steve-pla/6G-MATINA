function [TBS1,TBS2,TBS3, UE, uav_hotspots,uav_users,general_users,total_uav_users,remaining_users] = ue_tbs_export(area_min,area_max,N_users,uav_hotspot,lambda,uav_hotspot_radius)
% Define the area as a struct
area = struct('x_min', area_min, 'x_max', area_max, 'y_min', area_min, 'y_max', area_max);

% Define TBS positions as structs

TBS1 = struct('name', 'Upper Right', 'position', [area_max * 0.8, area_max * 0.8]);
TBS2 = struct('name', 'Upper Left', 'position', [area_min * 0.8, area_max * 0.8]);
TBS3 = struct('name', 'Bottom Center', 'position', [0, area_min * 0.8]);

% Generate UAV hotspots randomly in the area
uav_hotspots = struct('x', [], 'y', []);
for i = 1:uav_hotspot
    x = (area_max - area_min) * rand + area_min; % Random x-coordinate
    y = (area_max - area_min) * rand + area_min; % Random y-coordinate
    uav_hotspots(i).x = x;
    uav_hotspots(i).y = y;
end

% Generate users in UAV hotspots with Poisson-distributed numbers
uav_users = struct([]);
total_uav_users = 0; % Counter for total UAV users
for i = 1:uav_hotspot
    num_users = poissrnd(lambda); % Generate number of users for this hotspotΓ
    total_uav_users = total_uav_users + num_users;
    for j = 1:num_users
        angle = 2 * pi * rand; % Random angle
        radius = uav_hotspot_radius * sqrt(rand); % Random distance within the radius
        x = uav_hotspots(i).x + radius * cos(angle);
        y = uav_hotspots(i).y + radius * sin(angle);
        uav_users(end + 1).x = x; %#ok<SAGROW>
        uav_users(end).y = y;
    end
end

% Remaining users distributed in the general area
remaining_users = N_users - total_uav_users;
general_users = struct([]);
for i = 1:remaining_users
    x = (area_max - area_min) * rand + area_min;
    y = (area_max - area_min) * rand + area_min;
    general_users(end + 1).x = x; %#ok<SAGROW>
    general_users(end).y = y;
end

% Concatenate fields
UE = struct([])
for i = 1 : length(general_users)
    UE(i).x = general_users(i).x
    UE(i).y = general_users(i).y
end

j = length(general_users);
for i = 1 : length(uav_users)
    j = j + 1;
    UE(j).x = uav_users(i).x
    UE(j).y = uav_users(i).y
end

end


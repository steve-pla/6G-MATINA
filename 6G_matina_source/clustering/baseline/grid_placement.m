function [ABS_placement_data, vessel_associations] = grid_placement(Area_min_m, Area_max_m, N_abs, all_vessels_UEs, ABS_height_m)
% GRID_BASED_PLACEMENT Places ABSs on a grid and associates vessels.
%
% Inputs:
%   Area_min_m: Minimum x and y coordinate of the simulation area.
%   Area_max_m: Maximum x and y coordinate of the simulation area.
%   N_abs: The desired number of ABSs to place (will influence grid resolution).
%   all_vessels_UEs: A struct array containing information about the vessels,
%                    with '.x' and '.y' fields for coordinates.
%   ABS_height_m: The static height of all ABSs.
%
% Outputs:
%   ABS_placement_data: A 1xN_abs struct array where each element contains
%                     the x, y, z coordinates and index of an ABS placed
%                     on the grid.
%   vessel_associations: A N_vessels x 1 vector where the i-th element
%                        indicates the index of the ABS associated with the
%                        i-th vessel.

% 1. Place ABSs on a Grid
ABS_placement_data = struct([]);
side_length = sqrt(N_abs); % Try for a roughly square grid

% Adjust grid dimensions if N_abs is not a perfect square
num_rows = round(side_length);
num_cols = ceil(N_abs / num_rows);

x_coords = linspace(Area_min_m, Area_max_m, num_cols + 1); % Edges of cells
y_coords = linspace(Area_min_m, Area_max_m, num_rows + 1); % Edges of cells

abs_count = 1;
for i = 1:num_rows
    for j = 1:num_cols
        if abs_count <= N_abs
            x_center = (x_coords(j) + x_coords(j + 1)) / 2;
            y_center = (y_coords(i) + y_coords(i + 1)) / 2;
            ABS_placement_data(abs_count).x = x_center;
            ABS_placement_data(abs_count).y = y_center;
            ABS_placement_data(abs_count).z = ABS_height_m;
            ABS_placement_data(abs_count).index = abs_count;
            abs_count = abs_count + 1;
        end
    end
end

% 2. Associate Vessels to the Nearest ABS (Proximity-Based)
num_vessels = length(all_vessels_UEs);
vessel_associations = zeros(num_vessels, 1); % Initialize association vector

for i = 1:num_vessels
    vessel_pos = [all_vessels_UEs(i).x, all_vessels_UEs(i).y];
    min_distance = Inf;
    nearest_abs_index = -1;

    for j = 1:length(ABS_placement_data) % Use the actual number of placed ABSs
        abs_pos = [ABS_placement_data(j).x, ABS_placement_data(j).y];
        distance = sqrt(sum((vessel_pos - abs_pos).^2)); % Euclidean distance

        if distance < min_distance
            min_distance = distance;
            nearest_abs_index = j;
        end
    end
    vessel_associations(i) = nearest_abs_index;
end
end
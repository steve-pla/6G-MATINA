function [ABS_placement_data, vessel_associations] = random_uniform(Area_min_m, Area_max_m, N_abs, all_vessels_UEs, ABS_height_m)
% RANDOM_UNIFORM Places ABSs randomly and associates vessels.
%
% Inputs:
%   Area_min_m: Minimum x and y coordinate of the simulation area.
%   Area_max_m: Maximum x and y coordinate of the simulation area.
%   N_abs: The number of ABSs to place.
%   all_vessels_UEs: A struct array containing information about the vessels.
%                    It is assumed that each vessel has fields '.x' and '.y'
%                    representing its coordinates.
%   ABS_height_m: The static height of all ABSs.
%
% Outputs:
%   ABS_placement_data: A 1xN_abs struct array where each element contains
%                     the x, y, z coordinates and index of an ABS.
%   vessel_associations: A N_vessels x 1 vector where the i-th element
%                        indicates the index of the ABS associated with the
%                        i-th vessel.

% 1. Randomly Place ABSs
ABS_placement_data = struct([]);

for i = 1:N_abs
    ABS_placement_data(i).x = Area_min_m + (Area_max_m - Area_min_m) * rand();
    ABS_placement_data(i).y = Area_min_m + (Area_max_m - Area_min_m) * rand();
    ABS_placement_data(i).z = ABS_height_m;
    ABS_placement_data(i).index = i;
end

% 2. Associate Vessels to the Nearest ABS (Proximity-Based)
num_vessels = length(all_vessels_UEs);
vessel_associations = randi(N_abs, num_vessels, 1); % Uniform random assignment
end
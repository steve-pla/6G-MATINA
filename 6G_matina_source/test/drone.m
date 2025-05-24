function [Drone] = drone(method, UE, clusters, dHeight)
    % Function to create a struct array of drones based on clustering results
    % Inputs:
    %   method   - Clustering method ('kmeans', 'kmedoids', or 'fuzzy')
    %   UE       - Struct containing user equipment (UE) data (x,y)
    %   clusters - Number of clusters/drones to create
    %   dHeight  - Fixed height (z-coordinate) for the drones
    % Output:
    %   Drone    - Struct array containing drone positions and indices
    TableUE = struct2table(UE);
    data = TableUE(:, 1:2);
    data = table2array(data); 

    switch lower(method)
        case 'kmeans'
            
            [idx, C, sumd] = kmeans(data, clusters);
             Drone.SumD = sum(sumd);  % Assign SumD to the Drone structure
             Drone.idx = idx;      % Assign cluster indices
            
        case 'kmedoids'
      
            [idx, C] = kmedoids(data, clusters);
            total_distance = 0; % Initialize total_distance
            for i = 1:size(data, 1)
                min_dist = Inf;
                for j = 1:clusters
                    dist = norm(data(i,:) - C(j,:));
                    min_dist = min(min_dist, dist);
                end
                total_distance = total_distance + min_dist;
            end
            Drone.TotalDistance = total_distance; % Assign TotalDistance
            Drone.idx = idx;      % Assign cluster indices
                   
        case 'fuzzy'
            
            [centers, U] = fcm(data, clusters); 
            [~, idx] = max(U, [], 1);           
            idx = idx';                         
            C = centers;  
             Drone.PartitionCoefficient = sum(sum(U.^2))/size(data,1); % Assign PartitionCoefficient
            Drone.idx = idx;      % Assign cluster indices
            
        otherwise
            % Handle unknown clustering methods
            error('Unknown clustering method: %s', method);
    end

    for i = 1:clusters
        Drone(i).x = C(i, 1);  
        Drone(i).y = C(i, 2);    
        Drone(i).z = dHeight;  
        Drone(i).index = i;     
    end
end
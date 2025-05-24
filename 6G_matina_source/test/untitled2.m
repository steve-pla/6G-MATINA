% Example data (replace with your actual data)
num_abs = 30; % Replace with your number of ABSs
power_ranges = [5, 10, 15, 20]; % Average power values
num_powers = length(power_ranges);

% Example capacity calculation (replace with your actual model)
capacity_kmeans = zeros(num_powers, num_abs, 3);
capacity_kmedoids = zeros(num_powers, num_abs, 3);
capacity_fuzzy = zeros(num_powers, num_abs, 3);

for p = 1:num_powers
    for a = 1:num_abs
        % Calculate capacity from each TBS (example)
        capacity_kmeans(p, a, 1) = randi([10, 30]) + power_ranges(p);
        capacity_kmeans(p, a, 2) = randi([15, 35]) + power_ranges(p) * 1.2;
        capacity_kmeans(p, a, 3) = randi([20, 40]) + power_ranges(p) * 1.5;

        capacity_kmedoids(p, a, 1) = randi([15, 35]) + power_ranges(p) * 1.1;
        capacity_kmedoids(p, a, 2) = randi([20, 40]) + power_ranges(p) * 1.3;
        capacity_kmedoids(p, a, 3) = randi([25, 45]) + power_ranges(p) * 1.6;

        capacity_fuzzy(p, a, 1) = randi([20, 40]) + power_ranges(p) * 1.2;
        capacity_fuzzy(p, a, 2) = randi([25, 45]) + power_ranges(p) * 1.4;
        capacity_fuzzy(p, a, 3) = randi([30, 50]) + power_ranges(p) * 1.7;
    end
end

% Calculate maximum capacity per ABS, per ML, per power level
max_capacity_kmeans = zeros(num_powers, num_abs);
max_capacity_kmedoids = zeros(num_powers, num_abs);
max_capacity_fuzzy = zeros(num_powers, num_abs);

for p = 1:num_powers
    for a = 1:num_abs
        max_capacity_kmeans(p, a) = max(capacity_kmeans(p, a, :));
        max_capacity_kmedoids(p, a) = max(capacity_kmedoids(p, a, :));
        max_capacity_fuzzy(p, a) = max(capacity_fuzzy(p, a, :));
    end
end

% Calculate overall average capacity per ML, per power level
avg_capacity_kmeans = mean(max_capacity_kmeans, 2);
avg_capacity_kmedoids = mean(max_capacity_kmedoids, 2);
avg_capacity_fuzzy = mean(max_capacity_fuzzy, 2);

% Plotting (Logarithmic X-Axis)
figure;
semilogx(power_ranges, avg_capacity_kmeans, 'r-o', 'DisplayName', 'K-means');
hold on;
semilogx(power_ranges, avg_capacity_kmedoids, 'g-s', 'DisplayName', 'K-medoids');
semilogx(power_ranges, avg_capacity_fuzzy, 'b-^', 'DisplayName', 'Fuzzy C-means');
hold off;

% Labels and title
xlabel('Average TBS Transmit Power (Watts) - Log Scale');
ylabel('Average Maximum Downlink Capacity (Mbps)');
title('Average Maximum Capacity vs. Average TBS Power (Log Scale)');
legend('show');
grid on;
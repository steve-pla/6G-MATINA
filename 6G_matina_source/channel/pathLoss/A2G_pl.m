function PLdB = A2G_pl(r, h, fc)
    % Function to calculate the path loss in dB based on distance (r) and height (h)
    % Inputs:
    %   r - horizontal distance (in meters)
    %   h - height (in meters)
    % Outputs:
    %   PLdB - Path loss in decibels

    % Constants
    c = 3e8;   % Speed of light in meters per second
    %%%%%%%%f = 2e9;   % Frequency in Hz (2 GHz in this case)
    a = 9.61;  % Parameter for the Line-of-Sight (LoS) model
    b = 0.16;  % Parameter for the Line-of-Sight (LoS) model
    hNLoS = 20; % Path loss for Non-Line-of-Sight (NLoS) in dB
    hLoS = 1;   % Path loss for Line-of-Sight (LoS) in dB

    % Calculate the straight-line distance (d) between the transmitter and receiver
    d = sqrt(r.^2 + h.^2);  % Euclidean distance formula
    
    % Calculate the angle theta (in radians) between the horizontal distance and height
    theta = atan(h ./ r);   % Arctangent of height over horizontal distance
    
    % Line-of-sight probability model (PLoS) based on the angle theta
    PLoS = 1 ./ (1 + a .* exp(-b .* ((180/pi) .* theta - a)));  % LoS probability equation
    
    % Non-line-of-sight probability (PNLoS) is the complement of PLoS
    PNLoS = 1 - PLoS; 
    
    % Calculate the path loss in dB based on the given formula
    % The first part is the free-space path loss, and the rest adds the effects of LoS and NLoS
    PLdB = 20 .* log10((4 .* pi .* fc .* d) ./ c) + PLoS .* hLoS + PNLoS .* hNLoS;
end


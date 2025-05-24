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
function logger(MessageTitle)
% function logger(MessageTitle, Object)
%   logger Logs an error message and the error object details to a specified file.
%   log_error(MessageTitle, MessageTitle) writes a formatted
%   message including a timestamp, a title, the message from the
%   object, and the stack trace to the specified log file.
%
%   Inputs:
%       MessageTitle - A title for the error message (string).
%       Object     - The MATLAB error object (struct with fields like
%                         'message' and 'stack').
logFileName = 'logs\simulation_log_file.log';

    timestamp = datestr(now, 'yyyy-mm-dd HH:MM:SS');
    % fullMessage = sprintf('%s - %s:\n%s\nStack:\n%s\n', ...
    %                         timestamp, MessageTitle, Object.message);

    fullMessage = sprintf('%s - %s:\n%s\nStack:\n%s\n', ...
                             timestamp, MessageTitle);

    fileID = fopen(logFileName, 'a'); % Open the log file in append mode
    if fileID ~= -1
        fprintf(fileID, '%s', fullMessage);
        fclose(fileID);
    else
        warning('Unable to write to log file: %s', logFileName);
    end
end
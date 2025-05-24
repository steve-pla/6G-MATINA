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

%-------------------------------------
% MATLAB R2024b version 64-bit (win64)
% ------------------------------------

clear all;
clc;
% Add paths including folders and sub-folders.
% By alphabetic order.
addpath(genpath('channel\'));
addpath(genpath('clustering\'));
addpath(genpath('config\'));
addpath(genpath('logging\'));
addpath(genpath('logs\'));
addpath(genpath('optimizers\'));
addpath(genpath('simulation\'));
addpath(genpath('test\'));
addpath(genpath('visulization\'));
% Just call the 'maritime6G_runner.m' file to start all the simulation flow.
maritime6G_runner;


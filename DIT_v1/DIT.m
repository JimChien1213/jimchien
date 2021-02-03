%% Deficit Irrigation Toolbox (DIT) 1.0 beta
%
% VERSION: 1.0 (2nd April 2019)
%
% DESCRIPTION:
%	Deficit Irrigation Toolbox(DIT) is an open-source software to simulate crop-water productivity.
%	Written in Matlab language, the toolbox allows you to perform the complex analysis of crop yield
%	response to climate change, soil variability, and water management practices.
%
% INSTRUCTION:
%	To start a simulation, please define DIT_path and config_path of your project.
%	You can also copy the last section of the code to run several projects together.
%
% DEVELOPER:
%	Chair of Hydrology at TU Dresden(Germany):
%	- Prof. Dr. Niels Schütze
%	- Oleksandr Mialyk
%
% WEBSITE: bit.ly/TUD-DIT
%
% LICENSE: this code is distributed under the GNU LGPL license.
%
% NOTE: The code was written in Matlab R2017a and may not be compiled with older versions.

%% Initialization
close all; 
DIT_path = strcat(fileparts(mfilename('fullpath')),'\');
addpath(genpath([DIT_path 'Scripts'])); % Access the folder with scripts

%% Run DIT Projects
% Copy the section below to run several projects together

% ========== Start of the DIT Project ==========
    clearvars conf; fclose all; DIT_DefaultParams; % Clean up before running and get the default parameters
    
    % Access subfolders and configurations
    config_path = 'Projects/Uganda/Uganda_Config.m'; % Location of the configuration file #REQUIRED
    %config_path = 'Projects/Example5_GETOPTIS/Example5_Config.m'; % Location of the configuration file #REQUIRED
    
    run([DIT_path config_path]); 
    conf.location = DIT_path; % Load configurations
    
    % Here you can overwrite every configuration parameter #OPTIONAL

    RunDITProject(conf); % Run the toolbox
% ========== End of the DIT Project ==========
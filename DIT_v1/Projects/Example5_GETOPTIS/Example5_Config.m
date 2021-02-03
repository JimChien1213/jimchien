%% DIT configuration file
% The configuration parameters of a DIT project. Each of those parameters
% can be later overwritten in DIT.m

% Access the master configuration file
DIT_ConfigFull;

%% Scenario settings
% General
conf.project = 'Example5_GETOPTIS'; % The project name (same as project's folder name)
conf.saveas = 'Example5_Test_Run'; % The suffix of output files (e.g. MaizeOman)
conf.SimStart = datetime(2000,01,01); % Simulation starting date [yyyy,mm,dd]
conf.SimEnd = datetime(2010,12,31); % Simulation ending date [yyyy,mm,dd]
conf.save_data = true; % Save the outputs
conf.viz = true; % Plot & save graphs

%% Crop Model settings
conf.crop.model = 1; % 1 - Simple Soil-Water Balance Model(SWB)
conf.crop.name = 'Maize'; % Crop type [Maize, Tomato, Cotton, Wheat, Sunflower]
conf.crop.SeedingDate = '01/11'; % Seeding date, the growing season starts on the next day after this date [dd/mm]
conf.crop.HarvestDate = '01/04'; % Harvest date [dd/mm]
conf.crop.climate_file = 'Climate/ClimateOman_100years.txt'; % Climatic database (*.txt) = climatic database from Oman

% SWB settings
conf.SWB.D_file = 'Soil/SWB_RootDepth.txt'; % Root depth
conf.SWB.theta0 = 0.20; % Initial soil moisture
conf.SWB.fc = 0.35; % Field capacity
conf.SWB.pwp = 0.15; % Permanent wilting point   
        
%% Irrigation settings
conf.irr.strategy = 7; % 7 - Optimized deficit irrigation with GET-OPTIS
conf.irr.getoptis_mode = 1; % 1 - Random irrigation events with a minimum time lag between them
conf.irr.min_dt = 2; % Minimum time difference between irrigation events [0...inf days]
conf.irr.storage = 200; % Available water storage for irrigation [mm/season]
    % If you enter multiple storages, a Crop-Water Production Function(CWPF) will be activated, e.g. [0 200 400 600]

% Optimizer setup
conf.irr.optmz_population = 30; % Population size               !30 by default
conf.irr.optmz_end = 80; % Max number of population generations	!80 by default

% Objective function
conf.quan = 0.1; % Yields' quantile for an objective function 	!0.1 by default
conf.obj_function = 2; % Function type
    % Available options:
    % 1 - Quantile of the final crop yields = quantile(yields, conf.quan)
    % 2 - Quantile and mean of the final crop yields = quantile(yields, conf.quan) + mean(yields)
%% DIT configuration file
% The configuration parameters of a DIT project. Each of those parameters
% can be later overwritten in DIT.m

% Access the master configuration file
DIT_ConfigFull;

%% Scenario settings
% General
conf.project = 'Example3_Constant_Irrigation'; % The project name (same as project's folder name)
conf.saveas = 'Example3_Test_Run'; % The suffix of output files (e.g. MaizeOman)
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
conf.irr.strategy = 4; % 4 - Constant irrigation
conf.irr.step = 5; % Irrigate every X days
conf.irr.storage = 200; % Available water storage for irrigation [mm/season]
    % If you enter multiple storages, a Crop-Water Production Function(CWPF) will be activated, e.g. [0 200 400 600]
%% DIT configuration file
% The configuration parameters of a DIT project. Each of those parameters
% can be later overwritten in DIT.m

%% 1. Scenario settings
% General
conf.project = 'Uganda'; % The project name (same as project's folder name)
conf.saveas = 'Test'; % The suffix of output files (e.g. MaizeOman)
conf.SimStart = datetime(2000,01,01); % Simulation starting date [yyyy,mm,dd]
conf.SimEnd = datetime(2001,12,31); % Simulation ending date [yyyy,mm,dd]
conf.save_data = true; % Save the outputs

% Visualization
conf.viz = false; % Plot & save graphs
conf.fig_format = 'png'; % Only the formats supported by 'saveas' MATLAB function, e.g. png, pdf, jpg etc.
conf.fig_size = [600 550]; % Approximate figure size when saved [width height (in pixels)]
conf.hist_same_xaxis = false; % Set the same x-axis scale to each histogram 

%% 2. Calculation settings
conf.calc_mode = 1; % MATLAB calculation mode
    % Available options:
    % 1 - Standard calculation (recommended)
    % 2 - Parallel calculation (only for advanced MATLAB users, type 'help parfor')

%% 3. Crop Model settings
conf.crop.model = 1;
    % Available options:
    % 1 - Simple Soil-Water Balance Model(SWB)
    % 2 - AquaCropOS(AOS)
    
% 3.1 Common settings
conf.crop.name = 'Maize'; % Crop type
    % Available options for SWB: Maize, Tomato, Cotton, Wheat, Sunflower
        % (more have been added, see DIT_v1\Scripts\CropModels\SWB\SWB_CropParameters.m
    % Available options for AOS: Any (used only for log)
    
conf.crop.SeedingDate = '01/11'; % Seeding date, the growing season starts on the next day after this date [dd/mm]
conf.crop.HarvestDate = '01/03'; % Harvest date [dd/mm]
conf.crop.climate_file = 'Climate/ClimateUganda_10year.txt'; % Climatic database (*.txt)
% conf.crop.climate_file = 'Climate/ClimateOman_100years.txt'; % Climatic database (*.txt)

% % 3.2 SWB settings https://swb.readthedocs.io/en/latest/swb.html
conf.SWB.D_file = 'Soil/SWB_RootDepth.txt'; % Root depth
conf.SWB.theta0 = 0.20; % Initial soil moisture
conf.SWB.fc = 0.45; % Field capacity
conf.SWB.pwp = 0.20; % Permanent wilting point   
% conf.SWB.D_file = 'Soil/SWB_RootDepth.txt'; % Root depth
% conf.SWB.theta0 = 0.20; % Initial soil moisture
% conf.SWB.fc = 0.2; % Field capacity
% conf.SWB.pwp = 0.1; % Permanent wilting point   

% 3.3 AOS settings
% Find more info about AOS files in /Instructions/Literature/AquaCropOSv50a_ReferenceManual(2017).pdf
conf.AOS.crop_file = 'Crop/AOS_Crop_MaizeGDD.txt'; % Crop type
conf.AOS.crop_irr_file = 'Crop/AOS_IrrigationManagement.txt'; % Irrigation management
conf.AOS.cropmix_file = 'Crop/AOS_CropMix.txt';
conf.AOS.CO2_file = 'Climate/AOS_MaunaLoaCO2.txt'; % CO2 projection
conf.AOS.field_file = 'Crop/AOS_FieldManagement.txt'; % Field Management
conf.AOS.soil_file = 'Soil/AOS_Soil.txt'; % Soil
conf.AOS.soil_profile =  'Soil/AOS_SoilProfile.txt'; % Soil profile
% conf.AOS.soil_texture_file = 'Soil/AOS_SoilTexture_SandyClayLoam.txt'; % Soil file (if needed -> switch on "CalcSHP" in soil_file)
conf.AOS.soil_hyrdo_file = 'Soil/AOS_SoilHydrology.txt'; % Soil properties  !Overwritten if conf.combination = 2 or 3)
conf.AOS.soil_iniWC_file = 'Soil/AOS_InitialWaterContent.txt'; % Initial Water Content
% conf.AOS.soil_GW_file = 'Soil/AOS_WaterTable.txt'; % Groundwater Table (if needed -> switch on "Water table present" in soil_GW_file)

% 3.4 Multiple input files	!Implemented only for AOS now
conf.combination = 1; % Combination of input files
    % Available options:
    % 1 - Normal mode (same input files always)
    % 2 - Run many soil hydrology files for each growing season 
    % 3 - Run several random soil hydrology files for each growing season
        conf.soil.rand = 5; % Number of random soil hydrology files to consider

% Combination 2 and 3
conf.soil.num = 10; % Number of available soil hydrology files	!MUST be > 2
conf.soil.name = 'Soil/SoilVariability/AOS_SoilHydrology_AOS_Rosetta_'; % Name of the soil file without last number (for iteration)
        
%% 4. Irrigation settings
% 4.1 Irrigation limits
conf.irr.max = 50; % Maximum irrigation event [mm/event]	!50 by default
conf.irr.min = 1; % Minimum irrigation event [mm/event]     !1 by default

% Available water storage for irrigation
% If you enter multiple storages, a Crop-Water Production Function(CWPF) will be activated, e.g. [0 50 100 200]
conf.irr.storage = 200; % Water storage(s) [mm/season]      !Will be sorted and duplicates removed

% 4.2 Irrigation strategy
conf.irr.strategy = 7;
    % Available options:
    % 1 - No irrigation (rainfed)
    % 2 - Full irrigation (irrigate when WC < 90%)
    % 3 - Full irrigation with thresholds for soil moisture and irrigation:
        conf.irr.fc_threshold = 0.8; % Fraction of FC when to irrigate [from 0 to 1]
        conf.irr.irr_threshold = 0.5; % Fraction of the maximum irrigation [from 0 to 1]
    % 4 - Constant irrigation
        conf.irr.step = 5; % Irrigate every X days
        conf.irr.skip_seeding = false; % Skip irrigation on the seeding day (if your soil is preirrigated)
    % 5 - Optimized deficit irrigation with decision table  #OPTIMIZATION
    % 6 - Optimized deficit irrigation with decision table (considering 4 phenological stages)  #OPTIMIZATION
    % 7 - Optimized deficit irrigation with GET-OPTIS  #OPTIMIZATION
    % 8 - Defined irrigation schedule
        conf.irr.schedule_file = 'Crop/Irrigation/200_irr_schedule.txt';
    % 9 - Defined decision table
        conf.irr.dectab_file = 'Crop/Irrigation/DecisionTable_24.txt';

% 4.3 Irrigation optimization (#OPTIMIZATION strategies 5-7)
% Optimizer setup
conf.irr.optmz_population = 30; % Population size               !30 by default
conf.irr.optmz_end = 80; % Max number of population generations	!80 by default

% Objective function
conf.quan = 0.1; % Yields' quantile for an objective function 	!0.1 by default
conf.obj_function = 2; % Function type
    % Available options:
    % 1 - Quantile of the final crop yields = quantile(yields, conf.quan)
    % 2 - Quantile and mean of the final crop yields = quantile(yields, conf.quan) + mean(yields)

% % % Decision Table settings
% % conf.irr.DT_plot = false; % Plot decision table optimization process

% GET-OPTIS settings
conf.irr.getoptis_mode = 1;
    % Available options:
    % 1 - Random irrigation events with a minimum time lag between them
%         conf.irr.min_dt = 1; % Minimum time difference between irrigation events [0...inf days]
        conf.irr.min_dt = 0; % Minimum time difference between irrigation events [0...inf days]
   
    % 2 - Random irrigation volumes for the fixed day of the week
        conf.irr.day = 7; % Day of the week [1(Mon)-7(Sun)]
        conf.irr.skip_week = false; % Skip the first week
    % 3 - Random irrigation events with a fixed time lag between them
         conf.irr.dt = 1; % Fixed time difference between irrigation events [0...inf days]
%         conf.irr.dt = 5; % Fixed time difference between irrigation events [0...inf days]
        conf.irr.skip_event = false; % Skip the first irrigation event
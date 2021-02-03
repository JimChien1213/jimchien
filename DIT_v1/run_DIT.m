function run_DIT(varargin)
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
    %
    %INPUTS:
    %SimStart = The start day, month, and year of the simulation 
    %SimEnd = The end day, month, and year of the simulation
    %CropName = The name of the crop to be used in the simulation
    %SeedingDate = The first day the crop is seeded
    %HarvestDate = The day the crop is harvested
    %AOSFILE = The AquaCropOS files needed to run the simulation
    %DayMax = The max size of a single irrigation event for a single day
    %SeasonMax = The season limit on water usage

    %% Initialization
    %close all; 
    DIT_path = strcat(fileparts(mfilename('fullpath')),'\');
    %DIT_path = ''; % Path to DIT folder, e.g. 'My_models/DIT/' or leave '' if it is the current MATLAB folder #REQUIRED
    addpath(genpath([DIT_path 'Scripts'])); % Access the folder with scripts
    
    %% Parse Inputs
    %Allows for the optional inputs ('Year','Month','Day','Full')
    p = inputParser;
    %DEFAULT VALUES 
    NULL = '';
    DMax = 20;
    SMax = 200;
    %Accept user inputs: These need to be either strings numbers.
    %The defaults are in the Config file that is being called
    %'SimStart','SimEnd','CropName','SeedingDate','HarvestDate','AOSFILE','DayMax','SeasonMax'
    addOptional(p,'SimStart',NULL,@isstring)
    addOptional(p,'SimEnd',NULL,@isstring)
    addOptional(p,'CropName',NULL,@ischar)
    addOptional(p,'SeedingDate',NULL,@isstring)
    addOptional(p,'HarvestDate',NULL,@isstring)
    addOptional(p,'AOSFILE',NULL,@isstruct)
    addOptional(p,'DayMax',DMax,@isnumeric)
    addOptional(p,'SeasonMax',SMax,@isnumeric)
    addOptional(p,'IrrigationType',7,@isnumeric)
    addOptional(p,'CropModel',1,@isnumeric)
    parse(p,varargin{:});
    
    %Initialize the parse object
    SimStart = p.Results.SimStart;
    SimEnd = p.Results.SimEnd;
    CropName = p.Results.CropName;
    SeedingDate = p.Results.SeedingDate;
    HarvestDate = p.Results.HarvestDate;
    AOSFILE = p.Results.AOSFILE;
    DayMax = p.Results.DayMax;
    SeasonMax = p.Results.SeasonMax;
    IrrigationType = p.Results.IrrigationType;
    CropModel = p.Results.CropModel;
    
    %% Run DIT Projects
    % Copy the section below to run several projects together

    % ========== Start of the DIT Project ==========
    clearvars conf; fclose all; DIT_DefaultParams; % Clean up before running and get the default parameters
    
    % Access subfolders and configurations
    %IF THE CONFIG FOLDER IS CHANGED BELOW THEN THE RESULTS FOLDER IN
    %daily_scheduler.m ALSO NEEDS TO BE UPDATED TO MATCH
    config_path = 'Projects/Uganda/Uganda_Config.m'; % Location of the configuration file #REQUIRED
    %config_path = 'Projects/Oman/Config_Oman.m'; % Location of the configuration file #REQUIRED
    
    run([DIT_path config_path]); 
    conf.location = DIT_path; % Load configurations
    
    % Here you can overwrite every configuration parameter #OPTIONAL
    %% Start Times
    if ~isempty(SimStart) 
        conf.SimStart = SimStart;   % Simulation starting date [yyyy,mm,dd]
    end
    if ~isempty(SimEnd)
        conf.SimEnd = SimEnd; % Simulation ending date [yyyy,mm,dd]
    end
    
    %% Crop Data
    %% 3. Crop Model settings
    conf.crop.model = CropModel;
    % Available options:
    % 1 - Simple Soil-Water Balance Model(SWB)
    % 2 - AquaCropOS(AOS)
    
    if ~isempty(CropName)
        conf.crop.name = CropName; % Crop type
        CropBaseFile = 'Crop/AOS_Crop_';
        conf.AOS.crop_file = strcat(CropBaseFile,CropName,'GDD.txt');      %'Crop/AOS_Crop_MaizeGDD.txt'; % Crop type
    end
    % Available options for SWB: Maize, Tomato, Cotton, Wheat, Sunflower
    % Available options for AOS: Any (used only for log)
    if ~isempty(SeedingDate)
%         sd = split(SeedingDate,' ');
%         SeedingDate=strcat(sd(1),'/',sd(2));
        conf.crop.SeedingDate = convertStringsToChars(SeedingDate); % Seeding date, the growing season starts on the next day after this date [dd/mm],DIT requires character format,
    end
    if ~isempty(HarvestDate)
%         sd = split(SeedingDate,' ');
%         HarvestDate=strcat(sd(1),'/',sd(2));
        conf.crop.HarvestDate = convertStringsToChars(HarvestDate); % Harvest date [dd/mm],DIT requires character format,
    end
    
    %% AOS FILES
    conf.AOS.crop_file = strcat('Crop/AOS_Crop_',CropName,'GDD.txt');
    if ~isempty(AOSFILE)
        CropBaseFile = 'Crop/AOS_';
        ClimateBaseFile = 'Climate/AOS_';
        SoilBaseFile = 'Soil/AOS_';
        %conf.AOS.crop_file       = strcat(CropBaseFile,AOSFILE.crop_file);      %'Crop/AOS_Crop_MaizeGDD.txt'; % Crop type
        conf.AOS.crop_irr_file   = strcat(CropBaseFile,AOSFILE.crop_irr_file);       %'Crop/AOS_IrrigationManagement.txt'; % Irrigation management
        conf.AOS.cropmix_file    = strcat(CropBaseFile,AOSFILE.cropmix_file);   %'Crop/AOS_CropMix.txt';
        conf.AOS.CO2_file        = strcat(ClimateBaseFile,AOSFILE.CO2_file);       %'Climate/AOS_MaunaLoaCO2.txt'; % CO2 projection
        conf.AOS.field_file      = strcat(CropBaseFile,AOSFILE.field_file);     %'Crop/AOS_FieldManagement.txt'; % Field Management
        conf.AOS.soil_file       = strcat(SoilBaseFile,AOSFILE.soil_file);      %'Soil/AOS_Soil.txt'; % Soil
        conf.AOS.soil_profile    = strcat(SoilBaseFile,AOSFILE.soil_profile);   %'Soil/AOS_SoilProfile.txt'; % Soil profile
    %conf.AOS.soil_texture_file  = strcat(SoilBaseFile,AOSFILE.soil_texture_file);%'Soil/AOS_SoilTexture_SandyClayLoam.txt'; % Soil file (if needed -> switch on "CalcSHP" in soil_file)
        conf.AOS.soil_hydro_file = strcat(SoilBaseFile,AOSFILE.soil_hydro_file);%'Soil/AOS_SoilHydrology.txt'; % Soil properties  !Overwritten if conf.combination = 2 or 3)
        conf.AOS.soil_iniWC_file = strcat(SoilBaseFile,AOSFILE.soil_iniWC_file);     %'Soil/AOS_InitialWaterContent.txt'; % Initial Water Content
    %conf.AOS.soil_GW_file       = strcat(BaseFile,AOSFILE.soil_GW_file);   %'Soil/AOS_WaterTable.txt'; % Groundwater Table (if needed -> switch on "Water table present" in soil_GW_file)
    
        %conf.crop.name = AOSFILE.crop_file; % Crop type

    end
    
    %% 4. Irrigation settings
    % 4.1 Irrigation limits
    if DayMax ~= 0
        conf.irr.max = DayMax; % Maximum irrigation event [mm/event]	!50 by default
    end
    % Available water storage for irrigation
    % If you enter multiple storages, a Crop-Water Production Function(CWPF) will be activated, e.g. [0 50 100 200]
    if SeasonMax ~= 0
        conf.irr.storage = SeasonMax;   % Water storage(s) [mm/season]      !Will be sorted and duplicates removed
    end
    
    % 4.2 Irrigation strategy
    conf.irr.strategy = IrrigationType;
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

    
    
    RunDITProject(conf); % Run the toolbox
% ========== End of the DIT Project ==========
end
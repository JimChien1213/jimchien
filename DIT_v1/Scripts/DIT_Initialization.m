%% Description:
% DIT_Initialization prepares your DIT project for a simulation.
% The process is following:
% 1. Data validation
% 2. Create subfolders
% 3. Read data

%% 1. Data validation
if exist([conf.location 'Projects/' conf.project], 'dir') == 0
    error(['The folder with name "' conf.project '" does not exist']);
end
if conf.SimStart > conf.SimEnd
    error('You set the simulation start to be later than the simulation end');
end
if ismember(conf.irr.strategy, [1:3, 8:9])
%     warning('conf.irr.storage is set to 9999 mm due to the requirements of the selected irrigation strategy');
    conf.irr.storage = 9999;
end
if conf.crop.model == 1 && conf.combination > 1
    warning('conf.combination is set to 1 because it is not implemented for SWB yet');
    conf.combination = 1; 
end
if conf.irr.max < conf.irr.min
	error('conf.irr.max is lower than conf.irr.min');
end
if length(conf.irr.storage) > 1
    conf.cwpf = true;
end
if conf.cwpf && length(conf.irr.storage) == 1, error('CWPF steps were not defined, please add more numbers to conf.irr.storage or deactivate conf.cwpf'); end
if conf.soil.rand > conf.soil.num
    warning('conf.soil.rand is set to conf.soil.num because conf.soil.rand > conf.soil.num');
    conf.soil.rand = conf.soil.num;
end
if exist([conf.location 'Projects/' conf.project '/Data/' conf.soil.name num2str(conf.soil.num) '.txt'], 'file') == 0 && ismember(conf.combination, [2 3])
    error('conf.soil.num does not correspond to the number of available files');
end
if numel(conf.crop.model_full_names) < conf.crop.model || conf.crop.model < 1
    error('Wrong crop model was defined, please change conf.crop.model');
end
if numel(conf.calc_mode_name) < conf.calc_mode || conf.calc_mode < 1
    error('Wrong calculation mode was defined, please change conf.calc_mode');
end
if numel(conf.strategies) < conf.irr.strategy || conf.irr.strategy < 1
    error('Wrong irrigation strategy was defined, please change conf.irr.strategy');
end

%% 2. Create subfolders
% Create an output directory
if conf.save_data
    %conf.FileLocOut = [conf.location 'Projects/' conf.project '/Results/' conf.saveas '_' datestr(datetime('now'),'dd-mm-yyyy_HHMMSS')]; % Define the main output folder
    conf.FileLocOut = [conf.location 'Projects/' conf.project '/Results/' conf.saveas];
    if exist(conf.FileLocOut, 'dir') == 0, mkdir(conf.FileLocOut); end
    conf.save_path = string([conf.FileLocOut '/' conf.saveas]);
end

% Prepare for CWPFs calculation
conf.sims = string(conf.project); % Add the default name of the simulation
if conf.cwpf % Check if CWPFs is activated
    conf.irr.cwpf_steps = unique(sort(conf.irr.storage));
    conf.sims = string();
    for i = 1:numel(conf.irr.cwpf_steps)
        conf.sims(i) = strcat('CWPF/', num2str(conf.irr.cwpf_steps(i))); % Add simulation names
        if conf.save_data % Create additional output folders
            mkdir(char(strcat(conf.FileLocOut, '/', conf.sims(i))));
            conf.save_path(i) = strcat(conf.FileLocOut, '/', conf.sims(i), '/', conf.saveas, '_', num2str(conf.irr.cwpf_steps(i)));
        end 
    end
else, conf.irr.qmax = conf.irr.storage;
end

%% 3. Read data
conf.FileLocIn = [conf.location 'Projects/' conf.project '/Data'];
if conf.irr.strategy == 8, conf.DV = DIT_ReadIrrSchedule([conf.FileLocIn '/' conf.irr.schedule_file]); end % Read the irrigation schedule file
if conf.irr.strategy == 9, conf.DV = DIT_ReadDecisionTable([conf.FileLocIn '/' conf.irr.dectab_file])'; end % Read the decision table file

[Y, Irr, P, ET, DVs] = deal([]); % Create output arrays
save_data = conf.save_data; % Save some variables in case of the optimization

% Read climate and select a crop model function
switch conf.crop.model
    case 1 % SWB model      
        [weatherDB, conf] = SWB_ReadClimate(conf); % Read the climatic data
        crop_func = 'DIT_SoilWaterBalance'; % Name of the crop function
    case 2 % AOS model       
        [weatherDB, conf] = AOS_ReadClimate(conf);
        crop_func = 'DIT_AquaCropOS';
end
conf.crop.name = [upper(conf.crop.name(1)) lower(conf.crop.name(2:end))]; % Reformat the crop name
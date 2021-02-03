function [Y, P, ET, Irr] = AOS_GS(conf, weatherDB)
% AOS_GS runs a single growing season using an AquaCrop-OS crop model(AOS).
% Part of the code is taken from the code provided by Tim Foster (http://aquacropos.com/).
%
% FUNCTION:
%	function [Y, P, ET, Irr] = AOS_GS(conf, weatherDB)
%
% INPUT:
%	- "conf" are the configurations of your DIT project
%	- "weatherDB" is the database with climatic time-series
%
% OUTPUT:
%	- "Y" is the dry crop yield [ton/ha] 
%	- "P" is the total precipitation volume [mm]
%	- "ET" is the total evaporation volume [mm]
%	- "Irr" is the total irrigation volume [mm]
%
% DEVELOPER:
%	Chair of Hydrology at TU Dresden(Germany):
%	- Oleksandr Mialyk
%
% REFERENCE:
%	- Foster, T., Brozovi, N., Butler, A.P., Neale, C.M.U., Raes, D., Steduto, P., Fereres, E., Hsiao, T.C.:
%	  AquaCrop-OS: An open source version of FAO’s crop water productivity model. Agricultural Water Management,
%	  Vol. 181, S. 18-22, 2017, doi:10.1016/j.agwat.2016.11.015

%% 1. Initialization
% Declare global variables
global AOS_ClockStruct; global AOS_FileLoc; global AOS_InitialiseStruct;
AOS_FileLoc = struct();
AOS_FileLoc.Input = conf.FileLocIn;
AOS_FileLoc.Output = conf.FileLocOut;

AOS_Initialize(weatherDB,conf); % Set up AOS run

crop_type = AOS_InitialiseStruct.CropChoices{1}; % Get the crop type
seeding_day = datenum(conf.SimStart); harvest_day = datenum(conf.SimEnd);
conf.crop.gs = harvest_day - seeding_day + 1; % Growing season duration +1 to include the harvest date

% Define the irrigation strategy
switch conf.irr.strategy % Irrigation strategies
    case 1 % No irrigation(rainfed)
        cur_strat = 0; % Adjust the irrigation strategy number according to AquaCropOS code
    case 2 % Full irrigation (irrigate when WC < 90%)
        AOS_InitialiseStruct.IrrigationManagement.(crop_type).SMT(:) = 90; % Soil moisture threshold
        AOS_InitialiseStruct.IrrigationManagement.(crop_type).IT = 1; % Irrigation threshold
        cur_strat = 1;
    case 3 % Full irrigation with thresholds
        AOS_InitialiseStruct.IrrigationManagement.(crop_type).SMT(:) = conf.irr.fc_threshold * 100; % Soil moisture threshold
        AOS_InitialiseStruct.IrrigationManagement.(crop_type).IT = conf.irr.irr_threshold; % Irrigation threshold
        cur_strat = 1;
    case 4 % Constant irrigation
        irr_schedule = [AOS_ClockStruct.SimulationStartDate:AOS_ClockStruct.SimulationEndDate - 1]';
        storage = conf.irr.qmax;
        irr_events = floor((conf.crop.gs-1)/conf.irr.step) - conf.irr.skip_seeding; % Number of irrigation events
        irr_volume = round(conf.irr.qmax/irr_events,1); % Volume of an irrigation event
        if (irr_volume > conf.irr.max || irr_volume < conf.irr.min) && storage ~= 0
           error(['The max (' num2str(conf.irr.max) ' mm) and min (' num2str(conf.irr.min)...
                  ' mm) limits of an irrigation event (' num2str(irr_volume) ' mm) can''t be satisfied'...
                  ' for the current water storage, please change irrigation limits/storage']); 
        end
        for d = 1:irr_events % Create a schedule
            if ~conf.irr.skip_seeding % Skip irrigation on the seeding day
                irr_schedule((irr_schedule(:,1) == seeding_day), 2) = irr_volume;
                conf.irr.skip_seeding = 1;
                storage = storage-irr_volume;
            end
            irr_schedule((irr_schedule(:,1) == seeding_day + d*conf.irr.step), 2) = min(irr_volume, storage); 
            storage = storage-irr_volume;
            if storage < 0, storage = 0; end
        end
        AOS_InitialiseStruct.IrrigationManagement.(crop_type).IrrigationSch = irr_schedule;
        cur_strat = 3;
    case 5 % Optimized deficit irrigation with decision table
        DV = [conf.DV conf.DV conf.DV conf.DV];
        AOS_InitialiseStruct.InitialCondition.DV = DV;
        for gs = 1:AOS_ClockStruct.nSeasons
            AOS_InitialiseStruct.InitialCondition.irr_storage = conf.irr.qmax;
            AOS_InitialiseStruct.InitialCondition.irrstrg_avail(gs) = conf.irr.qmax;            
        end
        cur_strat = 5;
    case 6 % Optimized deficit irrigation with decision table(4 phenological stages)
        % Stage 1: Germination
        % Stage 2: Flowering
        % Stage 3: Grain-formation
        % Stage 4: Maturity
        DV = reshape(conf.DV,6,4);
        AOS_InitialiseStruct.InitialCondition.DV = DV;
        for gs = 1:AOS_ClockStruct.nSeasons
            AOS_InitialiseStruct.InitialCondition.irr_storage = conf.irr.qmax;
            AOS_InitialiseStruct.InitialCondition.irrstrg_avail(gs) = conf.irr.qmax;            
        end
        cur_strat = 5;
    case 7 % Optimized deficit irrigation with GET-OPTIS  
        irr_schedule = [AOS_ClockStruct.SimulationStartDate:AOS_ClockStruct.SimulationEndDate - 1]';
        for i = 1:length(conf.DV) % Create a schedule
            irr_schedule((irr_schedule(:,1) == seeding_day -1 + i),2) = conf.DV(i); 
        end
        AOS_InitialiseStruct.IrrigationManagement.(crop_type).IrrigationSch = irr_schedule;
        cur_strat = 3;
    case 8 % Defined schedule
        irr_schedule = [AOS_ClockStruct.SimulationStartDate:AOS_ClockStruct.SimulationEndDate - 1]'; 
        for i = 1:length(conf.DV) % Create a schedule
            irr_schedule((irr_schedule(:,1) == seeding_day - 1 + conf.DV(i,1)),2) = conf.DV(i,2); 
        end
        AOS_InitialiseStruct.IrrigationManagement.(crop_type).IrrigationSch = irr_schedule;
        cur_strat = 3;
    case 9 % Defined decision table
        if numel(conf.DV) == 6, DV = [conf.DV conf.DV conf.DV conf.DV]; else, DV = conf.DV; end
        AOS_InitialiseStruct.InitialCondition.DV = DV;
        for gs = 1:AOS_ClockStruct.nSeasons
            AOS_InitialiseStruct.InitialCondition.irr_storage = conf.irr.qmax;
            AOS_InitialiseStruct.InitialCondition.irrstrg_avail(gs) = conf.irr.qmax;            
        end
        cur_strat = 5;
    otherwise
        error('Wrong strategy number (check conf.irr.strategy)');
end

% Set irrigation limits
AOS_InitialiseStruct.IrrigationManagement.(crop_type).IrrMethod = cur_strat;
AOS_InitialiseStruct.IrrigationManagement.(crop_type).MaxIrr = conf.irr.max;
AOS_InitialiseStruct.IrrigationManagement.(crop_type).MinIrr = conf.irr.min;

%% 2. Calculate the crop yield
AOS_InitialiseStruct.Outputs.irr_schedule = [];
while AOS_ClockStruct.ModelTermination == false
    AOS_PerformTimeStep(); % Perform a single time-step (day)
end

%% 3. Save results
results = AOS_InitialiseStruct.Outputs.FinalOutput;

% Set final outputs
Y = results{7}; % Yields
P = results{9}; % Total P
ET = results{10}; % Total ET
Irr = results{8}; % Total IRR

% Save irrigation schedules
if conf.save_data
    if numel(conf.sims) > 1
        temp = char(strcat(conf.FileLocOut, '/', conf.sims(conf.sim), '/Irrigation_Schedules'));
    else
        temp = char(strcat(conf.FileLocOut, '/Irrigation_Schedules'));            
    end
    if ismember(conf.irr.strategy, [2, 3, 4, 7]) && Irr ~= 0
        if exist(temp, 'dir') == 0, mkdir(temp); end % Create a folder for schedules
        if ismember(conf.combination, [2 3]) && ismember(conf.irr.strategy, [2 3])
            irr_file = [temp '/AOS_GS', num2str(conf.gs), '_Soil', num2str(conf.soil.cur), '_irr_schedule.txt'];
        else
            irr_file = [temp '/AOS_GS' num2str(conf.gs) '_irr_schedule.txt'];
        end
        switch conf.irr.strategy
            case {4, 7} % Constant irrigation and GET-OPTIS
                if conf.gs == 1
                    fid = fopen(irr_file, 'w');
                    fprintf(fid,'%s\t%s\r\n%s\t%s\r\n%s\t%.1f%s',...
                        'Project: ', conf.project, 'Strategy:', char(conf.strategies(conf.irr.strategy)), 'Total irrigation volume:', sum(irr_schedule(:,2)),' mm');
                    fprintf(fid,'\r\n%s\r\n', 'Crop model: AquaCrop-OS');
                    fprintf(fid,'\r\n%s', 'Irrigation schedule (day 1 = seeding day): ');
                    fprintf(fid,'\r\n%s\t%s%s%s', 'Day', 'Water [',conf.units,']');
                    for d = 1 : size(irr_schedule,1)
                        fprintf(fid,'\r\n%i\t%.2f',d,irr_schedule(d,2));
                    end
                    fclose(fid);
                end
            case {2, 3} % Full irrigation
                irr_schedule = AOS_InitialiseStruct.Outputs.irr_schedule;
                fid = fopen(irr_file, 'w');
                fprintf(fid,'%s\t%s\r\n%s\t%s\r\n%s\t%.1f%s',...
                    'Project: ', conf.project, 'Strategy:', char(conf.strategies(conf.irr.strategy)), 'Total irrigation volume:', sum(irr_schedule(:,2)),' mm');
                fprintf(fid,'\r\n%s\r\n', 'Crop model: AquaCrop-OS');
                fprintf(fid,'\r\n%s', 'Irrigation schedule (day 1 = seeding day): ');
                fprintf(fid,'\r\n%s\t%s%s%s', 'Day', 'Water [',conf.units,']');
                for d = 1 : conf.crop.gs-1
                    temp = 0;
                    if ismember(d,irr_schedule(:,1))
                        temp = irr_schedule(irr_schedule(:,1) == d,2);
                    end
                    fprintf(fid,'\r\n%i\t%.2f',d,temp);
                end
                fclose(fid);
        end
    end
end

% Save original AOS report file (.txt)
%if conf.save_data, AOS_Finish(); end

end
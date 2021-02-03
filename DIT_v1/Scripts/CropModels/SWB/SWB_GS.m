function [Y, P, PET, Irr] = SWB_GS(conf, weatherDB)
% SWB_GS runs a single growing season using a Soil-Water Balance crop model(SWB).
%
% FUNCTION:
%	function [Y, P, ET, Irr] = SWB_GS(conf, weatherDB)
%
% INPUT:
%	- "conf" are the configurations of your DIT project
%	- "weatherDB" is the database with climatic time-series
%
% OUTPUT:
%	- "Y" is the dry crop yield [% of max] 
%	- "P" is the total precipitation volume [mm]
%	- "ET" is the total evaporation volume [mm]
%	- "Irr" is the total irrigation volume [mm]
%
% DEVELOPER:
%	Chair of Hydrology at TU Dresden(Germany):
%	- Prof. Dr. Niels Schütze
%	- Oleksandr Mialyk
%
% REFERENCE:
%	- Rao, N.H., Sarma, P.B.S., Chander Subhash: A simple dated water-production function for use in irrigated agriculture, 
%	  Agricultural Water Management, Vol. 13, S. 25-32, 1988 DOI: 10.1016/0378-3774(88)90130-8

%% 1. Initialization
if conf.crop.stages(end) < conf.crop.stages(end-1)
   error('The growing season is too short, please change conf.crop.HarvestDate and/or conf.crop.SeedingDate'); 
end

p = weatherDB(:,2); % Precipitation
et = weatherDB(:,3); % Potential evapotranspiration
D = weatherDB(:,4); % Root depth
irr = zeros(size(et,1)-1, 1); DV = ones(6,4);

% Define the irrigation strategy
switch conf.irr.strategy
    case 1 % No irrigation(rainfed)
    case 2 % Full irrigation (irrigate when WC < 90%)
    case 3 % Full irrigation with thresholds
    case 4 % Constant irrigation
        storage = conf.irr.qmax;
        irr_events = floor((conf.crop.gs-1)/conf.irr.step) - conf.irr.skip_seeding; % Number of irrigation events
        irr_volume = round(conf.irr.qmax/irr_events,1); % Volume of an irrigation event
        if (irr_volume > conf.irr.max || irr_volume < conf.irr.min) && storage ~= 0
           error(['The max (' num2str(conf.irr.max) ' mm) and min (' num2str(conf.irr.min)...
                  ' mm) limits of an irrigation event (' num2str(irr_volume) ' mm) can''t be satisfied'...
                  ' for the current water storage volume, please change irrigation limits/storage']); 
        end
        for d = 1:irr_events % Create a schedule
            if ~conf.irr.skip_seeding % Skip irrigation on the seeding day
                irr(1) = irr_volume;
                conf.irr.skip_seeding = 1;
                storage = storage-irr_volume;
            end
            irr(1 + d*conf.irr.step) = min(irr_volume,storage); 
            storage = storage-irr_volume;
            if storage < 0, storage = 0; end
        end
    case 5 % Optimized deficit irrigation with decision table
        DV = [conf.DV conf.DV conf.DV conf.DV];
    case 6 % Optimized deficit irrigation with decision table(4 phenological stages)
        % Stage 1: Germination
        % Stage 2: Flowering
        % Stage 3: Grain-formation
        % Stage 4: Maturity
        DV = reshape(conf.DV, 6, 4);
    case 7 % Optimized deficit irrigation with GET-OPTIS
        irr = conf.DV;
        if (conf.crop.gs-1) > numel(irr), irr = [irr; zeros(conf.crop.gs-1-numel(irr),1)]; end % Difference in day numbers
    case 8 % Defined schedule
        irr = conf.DV(:,2);
        if conf.crop.gs > numel(irr), irr = [irr; zeros(conf.crop.gs-numel(irr),1)]; end
    case 9 % Defined decision table
        if numel(conf.DV) == 6, DV = [conf.DV conf.DV conf.DV conf.DV]; else, DV = conf.DV; end
    otherwise
        error('Wrong strategy number');
end

%% 2. Calculate the crop yield
s = 1; % Crop stage index
[theta, aet, Pc, pet, q] = deal([]);
for d = 1:conf.crop.gs-1 % Iterate days (-1 for the harvest date)
    % Daily Boundary Conditions(BC)
    BC(d).PET = et(d);
    BC(d).P = p(d);
    BC(d).D = D(d);
    BC(d).dpl = SWB_DepletionFactor(BC(d).PET, conf.crop.name, 1); % Soil water depletion factor
    BC(d).irr = irr(d); % Initial irrigation schedule [L]               
%     ASW(d) = BC(d).D * (conf.SWB.fc - conf.SWB.pwp); % Potential Available Soil Water(ASW)[L]

    % Daily calculations
    if (d > conf.crop.stages(s)), s = s+1; end % Check current stage number
    if d == 1
        [theta(d), aet(d), Pc(d), pet(d), irr(d), q(d)] =... % Perform a single time-step (day)
            SWB_PerformTimeStep(conf, BC(d), conf.SWB.theta0, 0, conf.irr.qmax, DV(:,s));
    else
        [theta(d), aet(d), Pc(d), pet(d), irr(d), q(d)] =... % Perform a single time-step (day)
            SWB_PerformTimeStep(conf, BC(d), theta(d-1), (BC(d).D-BC(d-1).D), q(d-1), DV(:,s));
    end
end

% Final output calculations
Y = SWB_Yield([BC.PET], aet, 0, conf.crop);
Irr = sum(irr);
P = sum(p);
PET = sum(pet);
AET = sum(aet);
% mass_bal = conf.SWB.theta0 * BC(end).D - theta(end) * BC(end).D + Irr + P - sum(Pc) - AET; 

%% 3. Save results
% Save irrigation schedules
save_schedule = 1;
if ismember(conf.irr.strategy, [4,7]) && conf.gs ~= 1 % Don't save the same files again
    save_schedule = 0;
end
if save_schedule && conf.save_data
    if ismember(conf.irr.strategy, [2, 3, 4, 7]) && Irr ~= 0
        if numel(conf.sims) > 1
            temp = char(strcat(conf.FileLocOut, '/', conf.sims(conf.sim), '/Irrigation_Schedules'));
        else
            temp = char(strcat(conf.FileLocOut, '/Irrigation_Schedules'));            
        end
        if exist(temp, 'dir') == 0 && conf.gs == 1, mkdir(temp); end % Create a folder for irrigation schedules
        if ismember(conf.combination, [2 3]) && ismember(conf.irr.strategy, [2,3]) % Create a name
            irr_file = [temp '/SWB_GS', num2str(conf.gs), '_Soil', num2str(conf.soil.cur), '_irr_schedule.txt'];
        else
            irr_file = [temp '/SWB_GS' num2str(conf.gs) '_irr_schedule.txt'];
        end
        fid = fopen(irr_file, 'w');
        fprintf(fid,'%s\t%s\r\n%s\t%s\r\n%s\t%.1f%s',...
            'Project: ', conf.project, 'Strategy:', char(conf.strategies(conf.irr.strategy)), 'Total irrigation volume:', Irr,' mm');
        fprintf(fid,'\r\n%s\r\n', 'Crop model: Soil-Water Balance Model');
        fprintf(fid,'\r\n%s', 'Irrigation schedule (day 1 = seeding day): ');
        fprintf(fid,'\r\n%s\t%s%s%s', 'Day', 'Water [',conf.units,']');
        for d = 1:size(irr)
            fprintf(fid,'\r\n%i\t%.2f', d, irr(d));
        end
        fclose(fid);
    end
end

% Save daily data
% if conf.save_data
%     save([char(strcat(conf.save_path(conf.sim),'_y',num2str(conf.gs))) '_swb_daily.mat'],... % Save .mat file
%         'P','pet','aet','D','theta','q','Pc','irr',mass_bal);
% end
end
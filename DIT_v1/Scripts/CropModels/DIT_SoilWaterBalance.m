function [Y,P,ET,Irr] = DIT_SoilWaterBalance(conf, weatherDB)
% DIT_SoilWaterBalance runs a single Soil-Water Balance Model(SWB) simulation
% and processes/saves the seasonal outputs.
%
% FUNCTION:
%	function [Y, P, ET, Irr] = DIT_SoilWaterBalance(conf, weatherDB)
%
% INPUT:
%	- "conf" are the configurations of your DIT project
%	- "weatherDB" is the database with climatic time-series
%
% OUTPUT:
%	- "Y" are the dry crop yields [% of max] 
%	- "P" are the precipitation volumes [mm]
%	- "ET" are the evaporation volumes [mm]
%	- "Irr" are the irrigation volumes [mm]
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
% Additional crop & soil parameters
D = load([conf.FileLocIn '/' conf.SWB.D_file], '-ascii'); % Read root depth [L]
conf.crop = SWB_CropParameters(conf.crop);

% Simulation time boundaries
last_year = year(conf.SimEnd);
cur_year = year(conf.SimStart);

% Don't apply parfor for soil variability
temp_calc = 1;
if conf.combination == 2 && conf.calc_mode == 2
    conf.calc_mode = 1;
    temp_calc = conf.calc_mode;
end

%% 2. Run separately each growing season(GS)
switch conf.calc_mode
    case 1 % Standard calculation mode
        for s = 1:(last_year - cur_year + 1) % +1 because year numbers start from 0
            [gs_start, gs_end, stop_model] = DIT_AdjustGS(conf, s); % Adjust GS
            if ~stop_model
                weather_cut = ... % Extract weather for the current GS
                    weatherDB(find(weatherDB(:,1)==datenum(gs_start)) : find(weatherDB(:,1)==datenum(gs_end)), :); 
                pconf = conf; pconf.gs = s; pconf.SimStart = gs_start; pconf.SimEnd = gs_end;
                pconf.calc_mode = temp_calc;
%                 if (datenum(year(gs_end)+1,0,0) - datenum(year(gs_end),0,0))==366 %NotOriginal DIT
%                     pconf.crop.gs = datenum(gs_end) - datenum(gs_start); % Growing season duration +1 for include the harvest day
%                 else
                   pconf.crop.gs = datenum(gs_end) - datenum(gs_start) + 1; % Growing season duration +1 for include the harvest day
%                 end
                pconf.crop.stages = [cumsum(conf.crop.stages) pconf.crop.gs-1]; % Add the last growing stage
                weather_cut(:,4) = D(1:pconf.crop.gs); % Include the root depth
                [y(s,:), p(s,:), et(s,:), irr(s,:)] = SWB_GS(pconf, weather_cut); % Run the simulation
            end
        end
    case 2 % Parallel calculation mode
        parfor s = 1:(last_year - cur_year + 1) % +1 because year numbers start from 0
            [gs_start, gs_end, stop_model] = DIT_AdjustGS(conf, s); % Adjust GS
            if ~stop_model
                weather_cut = ... % Extract weather for the current GS
                    weatherDB(find(weatherDB(:,1)==datenum(gs_start)) : find(weatherDB(:,1)==datenum(gs_end)), :); 
                pconf = conf; pconf.gs = s; pconf.SimStart = gs_start; pconf.SimEnd = gs_end;
                pconf.calc_mode = temp_calc;
                pconf.crop.gs = datenum(gs_end) - datenum(gs_start) + 1; % Growing season duration +1 for include the harvest day
                pconf.crop.stages = [cumsum(conf.crop.stages) pconf.crop.gs-1]; % Add the last growing stage
                weather_cut(:,4) = D(1:pconf.crop.gs); % Include the root depth
                [y(s,:), p(s,:), et(s,:), irr(s,:)] = SWB_GS(pconf, weather_cut); % Run the simulation
            end
        end
    otherwise
        error('Wrong calculation mode was selected (check conf.calc_mode)');
end

%% 3. Finish simulation
Y = reshape(y',[],1); P = reshape(p',[],1); ET = reshape(et',[],1); Irr = reshape(irr',[],1); % Reshape in case of 2D array results, e.g. soil variability
Y = Y * 100; % Convert to percent

% Statistical analysis of results
meanY = round(mean(Y),2);
maxY = round(max(Y),2);
minY = round(min(Y),2);
quanY = round(quantile(Y,conf.quan),2);
meanIrr = round(mean(Irr));

% Display the summary of the simulation
if conf.show_log
    if ismember(conf.irr.strategy, [1,2,3,8]), temp = ' mm'; else, temp = [' out of ' num2str(conf.irr.qmax) ' mm']; end
%     disp(['   ~ Max/Mean/Min crop yields = ' num2str(maxY,3) '/' num2str(meanY,3) '/' num2str(minY,3) ' %, with irrigation ~'...
%           num2str(meanIrr) temp]);
end

% Save results (.txt, .mat)
if conf.save_data    
    % Save main seasonal outputs in .txt
    fid = fopen([char(conf.save_path(conf.sim)) '_SWB_seasonal.txt'], 'w');
    fprintf(fid,'%s\t%s\r\n%s\r\n',...
        'Project: ', conf.project, 'Crop model: Soil-Water Balance Model');
    fprintf(fid,'%s\t%s\r\n%s\t%s\r\n',...
        'Seeding date:', conf.crop.SeedingDate, 'Harvest date:', conf.crop.HarvestDate);
    fprintf(fid,'%s\t%s\r\n',...
        'Strategy:', char(conf.strategies(conf.irr.strategy)));
    fprintf(fid,'%s\t%.1f%s\r\n\r\n',...
        'Irrigation storage:', conf.irr.qmax,' mm');
    fprintf(fid,'%s\r\n%s\r\n',...
        'Crop yields [%]:',['mean - ' num2str(meanY,4), '; ' num2str(conf.quan*100,2) '% quantile - ' num2str(quanY,4)]);
    fprintf(fid,'\r\n%s%s%s\r\n%s\t%s\t%s\t%s\t%s\r\n',...
            'Totals [', conf.units,']:','Season','IRR','P','ET','Yield [%]');
    for s = 1:numel(Y)
        fprintf(fid, '%i\t%.2f\t%.2f\t%.2f\t%.2f\t\r\n', s, Irr(s), P(s), ET(s), Y(s));
    end
    fclose(fid);
    
    if ismember(conf.irr.strategy, [5 6]) % Save DVs
        % Save .mat file
        DV_opt = conf.DV;
        save([char(conf.save_path(conf.sim)) '_SWB_dectab_DV.mat'],'DV_opt'); 
        
        % Save .txt file
        fid = fopen([char(conf.save_path(conf.sim)) '_SWB_' num2str(conf.irr.qmax) 'mm_DVs.txt'], 'w');
        fprintf(fid, '%s\t%s\r\n%s\t%s\r\n%s\t%i%s\r\n',...
            'Project: ', conf.project, 'Strategy:', char(conf.strategies(conf.irr.strategy)), 'Total irrigation volume:', conf.irr.qmax,' mm');      
        fprintf(fid, '%s\r\n\r\n%s', 'Crop model: Soil-Water Balance Model', 'Decision variables:');
        
        [rows,cols] = size(DV_opt);
        fprintf(fid, '\r\n%s\t%s\t%s\t%s\t%s\t%s\r\n', 'X1', 'Y1', 'L1', 'L2', 'L3', 'L4');
        for c = 1:cols
            for r = 1:rows, fprintf(fid, '%.2f\t', DV_opt(r,c)); end
            fprintf(fid, '\r\n');
        end
        fclose(fid);
    end
end

Y = Y / 100; % Convert back to fraction
end
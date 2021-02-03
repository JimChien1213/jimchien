function [Y, P, ET, Irr] = DIT_AquaCropOS(conf, weatherDB)
% DIT_AquaCropOS runs a single AquaCrop-OS(AOS) simulation and processes/saves the seasonal outputs.
% The script is based on the AOS version 5.0a by Tim Foster(2017).
%
% FUNCTION:
%	function [Y, P, ET, Irr] = DIT_AquaCropOS(conf, weatherDB)
%
% INPUT:
%	- "conf" are the configurations of your DIT project
%	- "weatherDB" is the database with climatic time-series
%
% OUTPUT:
%	- "Y" are the dry crop yields [ton/ha] 
%	- "P" are the precipitation volumes [mm]
%	- "ET" are the evaporation volumes [mm]
%	- "Irr" are the irrigation volumes [mm]
%
% DEVELOPER:
%	Chair of Hydrology at TU Dresden(Germany):
%	- Oleksandr Mialyk
%
% REFERENCE:
%	- Foster, T., Brozovi, N., Butler, A.P., Neale, C.M.U., Raes, D., Steduto, P., Fereres, E., Hsiao, T.C.:
%	  AquaCrop-OS: An open source version of FAO’s crop water productivity model. Agricultural Water Management,
%	  Vol. 181, S. 18-22, 2017. DOI:10.1016/j.agwat.2016.11.015 (http://aquacropos.com/)

%% 1. Initialization
% Simulation time boundaries
last_year = year(conf.SimEnd);
first_year = year(conf.SimStart);

%% 2. Run separately each growing season(GS)
% Don't apply climatic parfor for soil variability
temp_calc = conf.calc_mode; conf.calc_mode = 1;
if temp_calc == 2 % Readjust parallel runs
    switch conf.combination
        case 2
            if conf.soil.num > (last_year - first_year)
                temp_calc = 1; conf.calc_mode = 2;
            end
        case 3
            if conf.soil.rand > (last_year - first_year)
                temp_calc = 1; conf.calc_mode = 2;
            end
    end
end

% Iterate growing seasons
switch temp_calc
    case 1 % Standard calculation mode
        for s = 1:(last_year - first_year + 1) % +1 because year numbers start from 0
            [gs_start, gs_end, stop_model] = DIT_AdjustGS(conf, s); % Adjust GS
            if ~stop_model
                weather_cut = ... % Extract weather for the current GS
                    weatherDB(find(weatherDB(:,1)==datenum(gs_start)) : find(weatherDB(:,1)==datenum(gs_end)), :);  
                pconf = conf; pconf.gs = s; pconf.SimStart = gs_start; pconf.SimEnd = gs_end;
                [y(s,:), p(s,:), et(s,:), irr(s,:)] = AOS_Combinations(pconf, weather_cut); % Run the simulation
            end
        end
    case 2 % Parallel calculation mode
        parfor s = 1:(last_year - first_year + 1) % +1 because year numbers start from 0
            [gs_start, gs_end, stop_model] = DIT_AdjustGS(conf, s); % Adjust GS
            if ~stop_model
                weather_cut = ... % Extract weather for the current GS
                    weatherDB(find(weatherDB(:,1)==datenum(gs_start)) : find(weatherDB(:,1)==datenum(gs_end)), :);  
                pconf = conf; pconf.gs = s; pconf.SimStart = gs_start; pconf.SimEnd = gs_end;
                [y(s,:), p(s,:), et(s,:), irr(s,:)] = AOS_Combinations(pconf, weather_cut); % Run the simulation
            end
        end
    otherwise
        error('Wrong calculation mode was selected (check conf.calc_mode)');
end

%% 3. Finish simulation
Y = reshape(y',[],1); P = reshape(p',[],1); ET = reshape(et',[],1); Irr = reshape(irr',[],1); % Reshape in case of 2D array results, e.g. soil variability

% Statistical analysis of results
meanY = round(mean(Y),2);
maxY = round(max(Y),2);
minY = round(min(Y),2);
quanY = round(quantile(Y,conf.quan),2);
meanIrr = round(mean(Irr));

% Display the summary of the simulation
if conf.show_log
    if ismember(conf.irr.strategy, [1,2,3,8]), temp = ' mm'; else, temp = [' out of ' num2str(conf.irr.qmax) ' mm']; end
%     disp(['   ~ Max/Mean/Min crop yields = ' num2str(maxY,3) '/' num2str(meanY,3) '/' num2str(minY,3) ' ton/ha, with irrigation ~'...
%           num2str(meanIrr) temp]);
end

% Save results (.txt, .mat)
if conf.save_data    
    % Save main seasonal outputs in .txt
    if conf.combination == 2, soil_num = conf.soil.num; % Get the number of considered soil hydrology files
    elseif conf.combination == 3, soil_num = conf.soil.rand;
    end
    fid = fopen([char(conf.save_path(conf.sim)) '_AOS_seasonal.txt'], 'w');
    fprintf(fid,'%s\t%s\r\n%s\r\n',...
        'Project: ', conf.project, 'Crop model: AquaCrop-OS');
    fprintf(fid,'%s\t%s\r\n%s\t%s\r\n',...
        'Seeding date:', conf.crop.SeedingDate, 'Harvest date:', conf.crop.HarvestDate);
    fprintf(fid,'%s\t%s\r\n',...
        'Strategy:', char(conf.strategies(conf.irr.strategy)));
    fprintf(fid,'%s\t%.1f%s\r\n\r\n',...
        'Irrigation storage:', conf.irr.qmax,' mm');
    fprintf(fid,'%s\r\n%s\r\n',...
        'Crop yields [ton/ha]:',['mean - ' num2str(meanY,4), '; ' num2str(conf.quan*100,2) '% quantile - ' num2str(quanY,4)]);
    fprintf(fid,'\r\n%s%s%s\r\n%s\t%s\t%s\t%s\t%s\r\n',...
            'Totals [', conf.units,']:', 'Season', 'IRR', 'P', 'ET', 'Yield [ton/ha]');
	switch conf.combination
        case 1
            for s = 1:numel(Y)
                fprintf(fid,'%i\t%.2f\t%.2f\t%.2f\t%.2f\t\r\n', s, Irr(s), P(s), ET(s), Y(s));
            end
        case {2, 3}
            for x = 1:soil_num
                fprintf(fid,'%s\t%i\r\n', 'Soil', x);
                for s = 1:length(y(:,x))
                    fprintf(fid,'%i\t%.2f\t%.2f\t%.2f\t%.2f\t\r\n', s,irr(s,x), p(s,x), et(s,x), y(s,x));
                end
                fprintf(fid,'\r\n');
            end
	end
    fclose(fid);
    
    if ismember(conf.irr.strategy, [5 6]) % Save DVs
        % Save .mat file
        DV_opt = conf.DV;
        save([char(conf.save_path(conf.sim)) '_AOS_dectab_DV.mat'], 'DV_opt'); 
        
        % Save .txt file
        fid = fopen([char(conf.save_path(conf.sim)) '_AOS_' num2str(conf.irr.qmax) 'mm_DVs.txt'], 'w');
        fprintf(fid,'%s\t%s\r\n%s\t%s\r\n%s\t%i%s\r\n',...
            'Project: ', conf.project, 'Strategy:', char(conf.strategies(conf.irr.strategy)), 'Total irrigation volume:', conf.irr.qmax,' mm');      
        fprintf(fid,'%s\r\n\r\n%s', 'Crop model: AquaCrop-OS', 'Decision variables:');
        
        [rows,cols] = size(DV_opt);
        fprintf(fid,'\r\n%s\t%s\t%s\t%s\t%s\t%s\r\n', 'X1', 'Y1', 'L1', 'L2', 'L3', 'L4');
        for c = 1:cols
            for r = 1:rows, fprintf(fid,'%.2f\t',DV_opt(r,c)); end
            fprintf(fid,'\r\n');
        end
        fclose(fid);
    end
end

end
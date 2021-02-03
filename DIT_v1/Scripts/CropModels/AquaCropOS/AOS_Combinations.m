function [Y, P, ET, Irr] = AOS_Combinations(conf, weather_cut)
% AOS_Combinations manages how to run one growing season simulation with AquaCrop-OS(AOS)
% and multiple input files. 
%
% FUNCTION:
%	function [Y, P, ET, Irr] = AOS_Combinations(conf, weather_cut)
%
% INPUT:
%	- "conf" are the configurations of your DIT project
%	- "weather_cut" is the database with climatic time-series for the current GS
%
% OUTPUT:
%	- "Y" are the dry crop yields [ton/ha] 
%	- "P" are the precipitation volumes [mm]
%	- "ET" are the evaporation volumes [mm]
%	- "Irr" are the irrigation volumes [mm]

switch conf.combination
    case 1 % Constant input files
        conf.soil.cur = 1;
        [Y, P, ET, Irr] = AOS_GS(conf, weather_cut); % Run AOS
    case 2 % Many soil hydrology files for one growing season
        [Y, P, ET, Irr] = deal(zeros(1, conf.soil.num));
        switch conf.calc_mode
            case 1
                for soil = 1:conf.soil.num % Standard mode
                    conf.soil.cur = soil;
                    conf.AOS.soil_hyrdo_file = [conf.soil.name num2str(soil) '.txt'];
                    [Y(soil), P(soil), ET(soil), Irr(soil)] = AOS_GS(conf, weather_cut); % Run AOS
                end
            case 2
                parfor soil = 1:conf.soil.num % Parallel mode
                    conf2 = conf;
                    conf2.soil.cur = soil;
                    conf2.AOS.soil_hyrdo_file = [conf2.soil.name num2str(soil) '.txt'];
                    [Y(soil), P(soil), ET(soil), Irr(soil)] = AOS_GS(conf2, weather_cut); % Run AOS
                end
        end
    case 3 % Random soil hydrology files for one growing season
        [Y, P, ET, Irr] = deal(zeros(1, conf.soil.rand));
        switch conf.calc_mode
            case 1
                for soil = 1:conf.soil.rand % Standard mode
                    conf.soil.cur = soil;
                    conf.AOS.soil_hyrdo_file = [conf.soil.name num2str(randi([1 conf.soil.num])) '.txt'];
                    [Y(soil), P(soil), ET(soil), Irr(soil)] = AOS_GS(conf, weather_cut); % Run AOS
                end
            case 2
                parfor soil = 1:conf.soil.rand % Parallel mode
                    conf2 = conf;
                    conf2.soil.cur = soil;
                    conf2.AOS.soil_hyrdo_file = [conf2.soil.name num2str(randi([1 conf2.soil.num])) '.txt'];
                    [Y(soil), P(soil), ET(soil), Irr(soil)] = AOS_GS(conf2, weather_cut); % Run AOS
                end
        end
    otherwise
        error('Wrong combination was selected, please change conf.combination');
end

end
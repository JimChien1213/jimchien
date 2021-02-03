function DV_opt = GET_OPTIS(conf, weatherDB) 
% GET_OPTIS optimizes the irrigation schedule using evolutionary algorithms
% created by Schütze et al.(2012).
%
% FUNCTION:
%	function DV_opt = GET_OPTIS(conf, weatherDB)
%
% INSTRUCTION:
%	The code is encrypted and requires to have an external objective function(crop model) with an access to transmitted to it variables.
%   This function must be called 'CalculateObjectiveFun' and recieve 'IRR', 'conf' & 'weatherDB' from GET-OPTIS.
%
% INPUT:
%	- "conf" are the configurations of your DIT project
%	- "weatherDB" is the database with climatic time-series
%
% OUTPUT:
%	- "DV_opt" are the optimized decision variables (irrigation schedule)
%
% DEVELOPER:
%	Chair of Hydrology at TU Dresden(Germany):
%	- Prof. Dr. Niels Schütze
%	- Oleksandr Mialyk
%   - Michael de Paly
%
% LICENSE: this code is distributed under the GNU LGPL license.
%
% REFERENCE:
%	- Schütze, N., Paly, M. & Shamir, U.: Novel Simulation-based algorithms for optimal open-loop and closed-loop
%	  scheduling of deficit irrigation systems. Journal of Hydroinformatics, Vol. 14.1, P. 136-151, 2012. DOI: 10.2166/hydro.2011.073

%% 1. Initialization
opt = struct();

% Calculate the growing season dates
opt.gs_start = datetime([num2str(year(conf.SimStart)) '/' conf.crop.SeedingDate],'InputFormat','yyyy/dd/MM'); % Start of GS
opt.gs_end = datetime([num2str(year(conf.SimStart)) '/' conf.crop.HarvestDate],'InputFormat','yyyy/dd/MM'); % End of GS
if opt.gs_start > opt.gs_end, opt.gs_end = opt.gs_end + calyears(1); end % Move to the next year for winter crops

% Optimize only when the water storage is not empty
if conf.irr.qmax == 0
	DV_opt = zeros(datenum(opt.gs_end) - datenum(opt.gs_start),1); return;
end

%% 2. Prepare parameters
% Check the running mode
opt.mode = conf.irr.getoptis_mode;
switch opt.mode
    case 1 % Random irrigation events with a minimum time lag between them
        opt.mindt = conf.irr.min_dt; % Minimum time difference between irrigation events [0...inf days]
    case 2 % Random irrigation volumes for the fixed day of the week
        opt.mindt = conf.irr.day; % Day of the week [1(Mon)-7(Sun)]
        opt.skip = conf.irr.skip_week; % Skip the first week
    case 3 % Random irrigation events with a fixed time lag between them
        opt.mindt = conf.irr.dt; % Fixed time difference between irrigation events [0...inf days]
        opt.skip = conf.irr.skip_event; % Skip the first irrigation event
end   

% Parameters for GET-OPTIS
opt.popsize = conf.irr.optmz_population; % Population size (number of schedules)
opt.endgen = conf.irr.optmz_end; % Max number of population generations (stopping criteria)
opt.watervol = conf.irr.qmax; % Water storage [mm]

% Irrigation limitations
opt.maxvol = conf.irr.max; % Maximum irrigation event [mm]
opt.minvol = conf.irr.min; % Minimum irrigation event [mm]

%% 3. Run GET-OPTIS
res = []; irrs = [];
GET_OPTIS_2019; % Import the code

% The optimal solution
best = find(res == max(res));
DV_opt = (irrs(best(1), :) / 1000)';

end
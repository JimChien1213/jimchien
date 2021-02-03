function DV_opt = DecisionTable(conf, weatherDB) 
% DecisionTable optimizes decision variables using CMA-ES optimization algorithms by Hansen et al.(2003).
% The code is based on the CMA-ES version 3.61 beta (April, 2012).
%
% DESCRIPTION:
%	There are 6 decision variables for each crop phenological stage [values from 0 to 1].
%	2 thresholds:
%       - Field Capacity threshold defines wet and dry soil
%       - Available water storage threshold defines few and much water
%	4 fractions of full irrigation for:
%       - Wet soil and few water
%       - Dry soil and few water
%       - Wet soil and much water
%       - Dry soil and much water
%
% FUNCTION:
%	function DV_opt = DecisionTable(conf, weatherDB)
%
% INPUT:
%	- "conf" are the configurations of your DIT project
%	- "weatherDB" is the database with climatic time-series
%
% OUTPUT:
%	- "DV_opt" are the optimized decision variables
%
% DEVELOPER:
%	Chair of Hydrology at TU Dresden(Germany):
%	- Prof. Dr. Niels Schütze
%	- Oleksandr Mialyk
%
% LICENSE: the original code is distributed under the GNU GPL license.
%
% REFERENCE:
%	- Hansen, N., Müller, S. D., Koumoutsakos, P.: Reducing the time complexity of the derandomized evolution strategy 
%	  with covariance matrix adaptation (CMA-ES). Journal of Evolutionary computation, Vol. 11, P. 1-18, 2003. DOI: 10.1162/106365603321828970

%% 1. Initialization
switch conf.irr.strategy
    case 5 % Without phenological stages (6 variables)
        p_mean = rand(6,1); % Initial decision variables
        p_var = ones(6,1) * 0.5 - 0.0001; % Deviations from p_mean      
        p_lb = zeros(6,1); % Minimum value of a decision variable
        p_ub = ones(6,1); % Maximum value of a decision variable
    case 6 % With 4 phenological stages (6 * 4 = 24 variables)
        p_mean = rand(24,1); % Look at case 5 for info 
        p_var = ones(24,1) * 0.5 - 0.0001;
        p_lb = zeros(24,1);
        p_ub = ones(24,1);
        % Sort water volume thresholds
        DV = reshape(p_mean, 6, 4); DV(2,:) = sort(DV(2,:), 'desc'); p_mean = reshape(DV,[],1);
end

% Optimize only when the water storage is not empty
if conf.irr.qmax == 0
	DV_opt = p_mean; return;
end

%% 2. Prepare parameters
opt = cmaes;
opt.MaxIter = 10000;
opt.PopSize = conf.irr.optmz_population; % Population size
opt.MaxFunEvals = conf.irr.optmz_end * opt.PopSize * 2; % Max number of evaluations
opt.TolX = 1e-4;
opt.TolHistFun = '1e-5';
opt.TolFun = '1e-4';
opt.Restarts = 0;
opt.LBounds = p_lb; opt.UBounds = p_ub;
opt.SaveVariables = 'off';
opt.DispModulo = 10;
opt.DispFinal = 'on';
opt.StopOnStagnation = 'on';
opt.LogModulo = 0;
if conf.irr.DT_plot, opt.LogPlot = 'on'; opt.LogModulo = 1; end
%opts.LogTime=0;

%% 3. Run Decision Table
[~,~,~,~,~, opt_sol] = cmaes('CalculateObjectiveFun', p_mean, p_var, opt, conf, weatherDB);
DV_opt = opt_sol.x; % Get optimal decision variables
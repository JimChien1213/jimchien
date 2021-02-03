function obj_fun = CalculateObjectiveFun(DV, conf, weatherDB)
% CalculateObjectiveFun calculates the objective function for irrigation optimization.
%
% FUNCTION:
%	function obj_fun = CalculateObjectiveFun(DV, conf, weatherDB)
%
% INPUT:
%	- "DV" are the decision variables
%	- "conf" are the configurations of your DIT project
%	- "weatherDB" is the database with climatic time-series
%
% OUTPUT:
%	- "obj_fun" is the objective function result

%% 1. Initialization
conf.DV = DV;
if conf.irr.strategy == 6 % Check if the decision table is sorted
    dvs = reshape(DV,6,4);
    if not(issorted(dvs(2,:), 'descend')), obj_fun = 0; return; end
end

%% 2. Calculate the crop yield
switch conf.crop.model
    case 1
        [yields, ~,~,~] = DIT_SoilWaterBalance(conf,weatherDB);
    case 2
        [yields, ~,~,~] = DIT_AquaCropOS(conf,weatherDB);
    otherwise
        error('Wrong crop model was selected, please check conf.crop.model');
end

%% 3. Calculate the objective function
switch conf.obj_function
    case 1 % Quantile of the final crop yields
       obj_fun = quantile(yields,conf.quan);
    case 2 % Quantile and mean of the final crop yields 
       obj_fun = quantile(yields,conf.quan) + mean(yields);
    otherwise
        error('Wrong objective function was selected, please check conf.obj_function');
end

if ismember(conf.irr.strategy,[5 6]) % Objective function should be negative for CMA-ES
    obj_fun = -obj_fun;
end
    
end
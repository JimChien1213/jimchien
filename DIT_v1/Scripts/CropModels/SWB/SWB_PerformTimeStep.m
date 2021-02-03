function [theta_new, AET, Pc, PET, Irr, Q] = SWB_PerformTimeStep(conf, BC, theta, DD, Q, DV)
% SWB_PerformTimeStep calculates actual evapotranspiration for one day
% basing on the equations by Rao(1987).
%
% FUNCTION:
%	function [theta_new, AET, Pc, PET, Irr, Q] = SWB_PerformTimeStep(conf, BC, theta, DD, Q, DV)
%
% INPUT:
%	- "conf" are the configurations of your DIT project
%	- "BC" are the initial boundary conditions
%	- "theta" is the initial soil moisture
%	- "DD" is the difference in the root depth between the current and previous timesteps[mm]
%	- "Q" is the initial water in the storage [mm]
%	- "DV" is the decision variables of the optimization
%
% OUTPUT:
%	- "theta_new" is the soil moisture
%	- "AET" is the actual evapotranspiration [mm]
%	- "Pc" is the percolation [mm]
%	- "PET" is the potential evapotranspiration [mm]
%	- "Irr" is the irrigation volume [mm]
%	- "Q" is the water available in storage [mm]
%
% DEVELOPER:
%	Chair of Hydrology at TU Dresden(Germany):
%	- Prof. Dr. Niels Schütze
%	- Oleksandr Mialyk
%
% REFERENCE:
%	- Rao, N.H.:Field test of a simple soil-water balance model for irrigated areas, 
%	  Journal of Hydrology, Vol. 91, p. 179-186, 1987 DOI: 10.1016/0022-1694(87)90135-1

%% Initial Conditions
% Soil parameters
theta0 = conf.SWB.theta0; % Soil moisture below the root depth
FC = conf.SWB.fc; % Filed capacity
PWP = conf.SWB.pwp; % Permanent wilting point

% Initial boundary conditions
PET = max(0.05, BC.PET); % Evapotranspiration
P = BC.P; % Precipitation
D = BC.D; % Root depth
Dpl = BC.dpl; % Soil water depletion factor

% Irrigation parameters
Q0 = conf.irr.qmax; % Initial Available water for irrigation
full = (FC-theta) * (D-DD) + (FC-theta0) * DD; % Potential full irrigation 
Irr = 0;

%% Calculation of irrigation for different irrigation scenarios
switch conf.irr.strategy
    case {1, 4, 7, 8} % Constant step and GET-OPTIS
        Irr = min(BC.irr, Q);
    case 2 % Full irrigation
        Irr = full;
    case 3 % Full irrigation with threshold
        if (theta <= FC * conf.irr.fc_threshold), Irr = full * conf.irr.irr_threshold; end
    case {5, 6, 9} % Decision Table
        % Field Capacity threshold
        X0 = 0; X1 = DV(1); X2 = 1;
        
        % Available water storge threshold
        Y0 = 0; Y1 = DV(2); Y2 = 1;
        
        % Decision Table limits
        L1 = DV(3);  % subject of optimization - case wet and few water
        L2 = DV(4);  % subject of optimization - case dry and few water
        L3 = DV(5);  % subject of optimization - case wet and much water
        L4 = DV(6);  % subject of optimization - case dry and much water
               
        % Decision Table IF Loops  
        if ((FC*X0)<=theta && theta<=(FC*X1) && (Q0*Y0)<=Q && Q<=(Q0*Y1)) % case dry and few water
            Irr = min((full*L2), Q);
        elseif ((FC*X1)<=theta && theta<=(FC*X2) && (Q0*Y0)<=Q && Q<=(Q0*Y1)) %case wet and few water
            Irr = min((full*L1), Q); 
        elseif ((FC*X0)<=theta && theta<=(FC*X1) && (Q0*Y1)<=Q && Q<=(Q0*Y2)) %case dry and much water
            Irr = min((full*L4), Q);
        elseif ((FC*X1)<=theta && theta<=(FC*X2) && (Q0*Y1)<=Q && Q<=(Q0*Y2)) %case wet and much water
            Irr = min((full*L3), Q);
        end
    otherwise
        error('Wrong strategy number')
end

% Limit irrigation
Irr = min(conf.irr.max, Irr); % Max
if Irr < conf.irr.min, Irr = 0; end % Min

% Irrigation reservoir balance
Q = Q - Irr;  % Deduct irrigation from storage

% Percolation
if (P + Irr >= (FC-theta)*D + (FC-theta0)*DD)
    Pc = P + Irr - ((FC-theta)*D + (FC-theta0)*DD);
else
    Pc = 0;
end

% Actual evapotranspiration
AET_old = 0.0; AET = PET;
while abs(AET - AET_old) > 0.0001
    theta_new = min([FC, max([PWP, (theta*(D-DD) + Irr + P - AET_old - Pc + theta0*DD)/D])]);
    AET_old = AET;
    if theta_new <= PWP
        AET = 0.0;
    elseif (theta_new-PWP >= (1-Dpl)*(FC-PWP))
        AET = min([(theta_new-PWP)*D, PET]);
    else
        AET = (theta_new-PWP) * PET / ((1-Dpl) * (FC-PWP));
    end
    theta_new = min([FC, max([PWP, (theta*(D-DD) + Irr + P - AET - Pc + theta0*DD)/D])]);
end

end
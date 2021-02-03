function [gs_start, gs_end, stp_mod] = DIT_AdjustGS(conf, gs)
% DIT_AdjustGS calculates time boundaries of the current growing season(GS).
%
% FUNCTION:
%	function [gs_start, gs_end, stp_mod] = DIT_AdjustGS(conf, gs)
%
% INPUT:
%	- "conf" are the configurations of your DIT project
%	- "gs" is the current GS
%
% OUTPUT:
%	- "gs_start" is the first day of GS
%	- "gs_end" is the last day of GS
%	- "stp_mod" is the stopping trigger

stp_mod = 0;
cur_year = year(conf.SimStart) + gs - 1; % Get the current year
gs_start = datetime([num2str(cur_year) '/' conf.crop.SeedingDate], 'InputFormat','yyyy/dd/MM'); % Start of the GS
gs_end = datetime([num2str(cur_year) '/' conf.crop.HarvestDate], 'InputFormat','yyyy/dd/MM'); % End of the GS

% Check whether the GS is within the time limits of the simulation
if gs_start > gs_end
    gs_end = gs_end + calyears(1);
    if gs_end > conf.SimEnd, stp_mod = 1; end
end
    
end
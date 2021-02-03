function relY = SWB_Yield(PET, AET, eq, crop)
% SWB_Yield calculates a relative yield as a AET/PET ratio.
%
% FUNCTION:
%	function relY = SWB_Yield(PET, AET, eq, crop)
%
% INPUT:
%	- "PET" is the potential evapotranspiration [mm]
%	- "AET" is the actual evapotranspiration [mm]
%	- "eq" is equation type switch
%	- "crop" is the crop parameters
%
% OUTPUT:
%	- "relY" is the relative crop yield [% of max] 

%% Explanations
% Crop parameters:
%	stages - duration of phenological stages [days]
%	ky - mean crop sensitivity coefficient (linear case)
%	KY - sensitivity coefficients per crop growth stage (non-linear case)
% Stages:
%	Stage 1: Initial from planting to approximately 10% ground cover
%	Stage 2: Crop-development from 10% to effective full cover and flowering
%	Stage 3: Mid-season from flowering to start of senescence, the longest period
%	Stage 4: Late season from maturity to harvest (calculated outside)

if sum(AET) == 0, relY = 0; return; end

%% Initialization
stages = [0 crop.stages];
relY = 1;

%% Yield calculation
if eq == 0
    for i = 1:length(crop.KY)
        AETi = []; PETi = [];
        AETi = AET(stages(i) + 1:stages(i+1));
        PETi = PET(stages(i) + 1:stages(i+1));
        relY = (1 - crop.KY(i) * (1 - sum(AETi)/sum(PETi))) * relY;
    end
else
    relY = (1 - crop.ky * (1 - sum(AET)/sum(PET)));
end

if relY < 0, relY = 0; end

end
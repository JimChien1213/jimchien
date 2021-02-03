function crop = SWB_CropParameters(crop)
% SWB_CropParameters gets additional crop parameters using data form CropWat 4 software(FAO).
%
% FUNCTION:
%	function crop = SWB_CropParameters(crop)
%
% INPUT:
%	- "crop" are the basic crop parameters
%
% OUTPUT:
%	- "crop" are the complete crop parameters

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

switch lower(crop.name)
    case 'maize'
        crop.stages = [25 40 40]; % Duration of phenological stages 
        crop.ky = 1.25;
        crop.KY = [0.4 0.4 1.3 0.5];
    case 'tomato'
        crop.stages = [30 40 40];
        crop.ky = 1.05;
        crop.KY = [0.5 0.6 1.1 0.8];
    case 'cotton'
        crop.stages = [30 50 60];
        crop.ky = 0.85;
        crop.KY = [0.4 0.4 0.5 0.4];
    case 'wheat'    %Winter wheat?
        crop.stages = [30 30 40];
        crop.ky = 1.0;
        crop.KY = [0.4 0.6 0.8 0.4];
    case 'sunflower'
        crop.stages = [25 35 45];
        crop.ky = 0.95;
        crop.KY = [0.4 0.6 0.8 0.8];
    
    %% Added Cases 
    % ky and KY according to FAO paper: http://www.fao.org/3/i2800e/i2800e02.pdf
    % Used table 2 for four different KY values where Tr-0111 = Stage 1,
    % Tr-1011 = Stage 2, Tr-1101 = Stage 3, and Tr-1110 = Stage 4
    %
    % Stages according to https://www.scscourt.org/complexcivil/105CV049053/volume3/172618e_5xAGWAx8.pdf
    % 
    
    case 'alfalfa'
        crop.stages = [10 30 25];   %1st cutting cycle Idaho
        crop.ky = 1.1;
    case 'banana'
        crop.stages = [120 90 120]; %1st year
        crop.ky = 1.25; %1.2-1.35
    case 'drybean'  %Also referred to as beans in the paper
        %crop.stages = [29 21 55]; %Source: Used bush variant https://www.ag.ndsu.edu/crops/dry-bean-articles/stages-of-development
        crop.stages = [20 30 40];
        crop.ky = 1.15;
        crop.KY = [0.2 1.1 0.75 0.2];
    case 'cabbage'
        crop.stages = [40 60 50];
        crop.ky = 0.95;
    case 'groundnuts'
        crop.stages = [25 35 45];
        crop.ky = 0.70;
        crop.KY = [0.2 0.8 0.6 0.2];
    case 'onion'
        crop.stages = [15 25 70];
        crop.ky = 1.1;
    case 'peas'
        crop.stages = [15 25 35];
        crop.ky = 1.15; 
    case 'pepper'
        crop.stages = [25 35 40];
        crop.ky = 1.1;
    case 'potato'
        crop.stages = [25 30 40];   %semi-arid; See reference for more options
        crop.ky = 1.1;
        crop.KY = [0.6 0.33 0.7 0.2]; %Stage 2 came from IAEA numbers
    case 'paddyrice'
        crop.stages = [30 30 60];
        crop.ky = 1.15;     %THIS IS A GUESS
        crop.KY = [0.2 0.6 1.25 0.4];   %Source: (page 125)  https://www.scielo.br/pdf/pab/v48n2/48n02a01.pdf
    case 'safflower'
        crop.stages = [20 35 45];
        crop.ky = 0.8;
    case 'sorghum'
        crop.stages = [20 35 45];   %arid region
        crop.ky = 0.9;        
    case 'soybean'
        %crop.stages = [30 21 70]; %Source: Used V3, R2, R8 https://extension.umn.edu/growing-soybean/soybean-growth-stages#reproductive-phase-%28table-2%29-539861
        crop.stages = [15 15 40];   %Tropic
        crop.ky = 0.85;
%          crop.KY = [0.06 0.17 0.89 0.08];   %Source: https://www-cambridge-org.proxy.lib.umich.edu/core/services/aop-cambridge-core/content/view/DB059CC032A27B7C5A07FF896F56E8D5/S0021859615000313a.pdf/soybean_yield_gap_in_brazil_magnitude_causes_and_possible_solutions_for_sustainable_production.pdf
        crop.KY = [0.2 0.8 1.0 0.2];   %FAO source: where the Stage 4 was taken from using the most common Stage 4 K value
    case 'spring wheat'
        crop.stages = [40 30 40];
        crop.ky = 1.15;
        crop.KY = [0.2 0.65 0.55 0.2];
    case 'sugarbeet'
        crop.stages = [30 45 90]; %Mediterranean if arid [25 30 25]
        crop.ky = 1;
    case 'sugarcane'
        crop.stages = [50 70 220];  %Tropics
        crop.ky = 1.2;
        crop.KY = [0.75 1.2 0.5 0.1];   %Combination of FAO and IAEA numbers
    case 'watermelon'
        crop.stages = [20 30 30];
        crop.ky = 1.1;
    otherwise
        error(['Crop "' crop.name '" does not exist']);
end

end
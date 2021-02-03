function Dpl = SWB_DepletionFactor(PET, crop, cont)
% SWB_DepletionFactor calculates storage depletion factor basing on Doorenbos et al.(1979).
%
% FUNCTION:
%	function Dpl = SWB_DepletionFactor(PET, crop, cont)
%
% INPUT:
%	- "PET" is the potential evapotranspiration amount [mm]
%	- "crop" are the crop parameters
%	- "cont" is the equation type switch
%
% OUTPUT:
%	- "Dpl" is the storage depletion factor [mm]
%
% REFERENCE:
%	- Doorenbos, J. & Kassam, A.H. 1979. Yield response to water. 
%	  FAO Irrigation and Drainage Paper No. 33. Rome, FAO. 

if cont
    switch lower(crop)
        case {'cotton','maize','olive','safflower','sorghum','soybean','sugarbeet','sugarcane','tobacco'}
            param = [21.4518598793586,11.4574423725921,7.06810298502924,13.9664675649906,13.9664887117557,5.00633232612809,-0.695276470992518,-0.703409768593584,-0.408058980042724,-0.197167406246837,-0.197167089439547,-1.32902072410612;];
            weights = [-0.0170034595735286,0.0659401623113020,0.147844188255071,6896.72806545249,-6896.70645783522,0.663468651767769;];
        case {'onion','pepper','potato'}
            param = [5.00250651888195,19.9945801067095,5.34631383624168,39.4829026516903,5896.49503958127,6.01749089449040,-0.555657789903010,-0.154220139521857,0.274403785448663,-0.945853799221765,-0.990351032012358,-0.261802946263552;];
            weights = [0.0727458715670829,-0.0280528569312130,-0.267374664078816,0.00747808970767256,0.0891051787254242,0.126281116468434;];
        case {'banana','cabbage','grape','pea','tomato'}
            param = [7.59216043207208,8.59967458403356,954.156963385408,5.00000163744826,14.0601744494127,32.9559214816057,-0.776127679827099,-0.470182475732520,-0.991721992761646,0.497870732087272,-0.328647525423953,-0.238539374506699;];
            weights = [0.0571516643335468,0.0754616947000629,0.115911993479311,-0.339054085975191,0.0627127857912147,0.0280805398850936;];
        case {'alfalfa','bean','citrus','groundnut','pineapple','paddyrice','sunflower','watermelon','wheat'}    % Added Rice to the original function
            param = [6.59774070161098,6.60230004481630,202.943223945264,190.596967527486,5.00413797577847,5.00424371844147,6.60479924071046,-0.801215853185580,-0.295211017418803,-0.998357678942309,-1.00080545894376,-0.0684518475458694,-0.0684491653951669,-0.295256256843844;];
            weights = [0.0726802359781857,1190.55000640130,0.397656504447288,-0.240846991510245,-55216.1140176426,55214.2297590174,-1188.89477682954;];
    end
    n = length(param');
    PAR = reshape(param', n/2, 2);
    kappas = PAR(:,1);
    thetas = PAR(:,2);
    yoffset = zeros(n/2,1);
    PET = PET/10; % Convert to cm 
    Dpl = kernel_sigm(PET', 1, kappas, thetas, weights', yoffset);    
else
    switch lower(crop)
        case {'cotton','maize','olive','safflower','sorghum','soybean','sugarbeet','sugarcane','tobacco'}
            PP = [0.88 0.8 0.7 0.6 0.55 0.5 0.45 0.43 0.4 0.0];

        case {'onion','pepper','potato'}
            PP = [0.50 0.425 0.35 0.30 0.25 0.225 0.20 0.20 0.175 0.0];

        case {'banana','cabbage','grape','pea','tomato'}
            PP = [0.675 0.575 0.475 0.40 0.35 0.325 0.275 0.25 0.225 0.0];

        case {'alfalfa','bean','citrus','groundnut','pineapple','paddyrice','sunflower','watermelon','wheat'} %Added rice to the original function
            PP = [0.80 0.70 0.60 0.50 0.45 0.425 0.375 0.35 0.30 0.0];
    end

    XX = [0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.000001];

    for i = 1:length(PET)
         if PET(i) < XX(1)
            Dpl(i) = PP(1);
        elseif PET(i) < XX(2)   
            Dpl(i) = PP(1) + (PP(1)-PP(2)) / (XX(1)-XX(2)) * (PET(i) - XX(1));
        elseif PET(i) < XX(3) 
            Dpl(i) = PP(2) + (PP(2)-PP(3)) / (XX(2)-XX(3)) * (PET(i) - XX(2));
        elseif PET(i) < XX(4)  
            Dpl(i) = PP(3) + (PP(3)-PP(4)) / (XX(3)-XX(4)) * (PET(i) - XX(3));
        elseif PET(i) < XX(5)  
            Dpl(i) = PP(4) + (PP(4)-PP(5)) / (XX(4)-XX(5)) * (PET(i) - XX(4));
        elseif PET(i) < XX(6)
            Dpl(i) = PP(5) + (PP(5)-PP(6)) / (XX(5)-XX(6)) * (PET(i) - XX(5));
        elseif PET(i) < XX(7) 
            Dpl(i) = PP(6) + (PP(6)-PP(7)) / (XX(6)-XX(7)) * (PET(i) - XX(6));
        elseif PET(i) < XX(8) 
            Dpl(i) = PP(7) + (PP(7)-PP(8)) / (XX(7)-XX(8)) * (PET(i) - XX(7));
        elseif PET(i) < XX(9)
            Dpl(i) = PP(8) + (PP(8)-PP(9)) / (XX(8)-XX(9)) * (PET(i) - XX(8));
        else
            Dpl(i) = 0;
        end
    end
end

end
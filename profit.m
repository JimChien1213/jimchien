function profit_total = profit(x)
%Filename: profit.m
%profit(x): returns the negative profit for the crop/pump/energy system
%INPUT: x = [proportion_crop, pump, Number_solarpanels, Number_batteris, Power_dieselgenerator];
%OUTPUT: negative profit
%
    %% Initialize parameters
    Param = system_param();

    %% Setup Variables
    %Variables x = [x.acrop, x.Npv, x.Nbat, x.pump];
    micro_x = [round(x(6)),round(x(7)),x(8)];   %The NumPV and Numbatteries are rounded to the nearest integer to allow for the optimization model to treat them as continuous variables without producing an error in the energy subsystem
    crop_x = [x(1),x(2),x(3),x(4)];
    %pump_x = x(5);

    %% Revenues
     %Crop Revenue
    tic
    [total_rev_crop,irr_demand] = get_crop_revenue(crop_x);
    toc
     %NonCrop Revenue
    rev_noncrop = 0;
     %Total Revenue
    revenue_total = total_rev_crop + rev_noncrop;
 
    %% Costs
     %Cost of the Crops
    cost_crop = total_crop_cost(crop_x);
     %Cost of pump
    cost_pump = pump_cost(irr_demand, crop_x); 
     %Cost of Irrigation
    cost_irrigation = irrigation_cost(crop_x);
     %Cost of the microgrid
    tic
    [cost_micr, emission_micr] = cost_micro(micro_x);
    if isnan(cost_micr)
        cost_micr = 10^10;
    end
    toc
     %Total 
    cost_total = cost_micr + cost_pump + cost_irrigation + cost_crop;
    
    %% Profit
    profit_total = revenue_total - cost_total;
end
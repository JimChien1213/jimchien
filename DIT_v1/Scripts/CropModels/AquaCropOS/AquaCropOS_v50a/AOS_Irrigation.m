function [NewCond,Irr] = AOS_Irrigation(InitCond,IrrMngt,Crop,Soil,...
    AOS_ClockStruct,GrowingSeason,Rain,Runoff)
% Function to get irrigation depth for current day

%% Store intial conditions for updating %%
NewCond = InitCond;

%% Calculate root zone water content and depletion %%
[~,Dr,TAW,thRZ] = AOS_RootZoneWater(Soil,Crop,NewCond);

%% Determine adjustment for inflows and outflows on current day %%
if thRZ.Act > thRZ.Fc
    rootdepth = max(InitCond.Zroot,Crop.Zmin);
    AbvFc = (thRZ.Act-thRZ.Fc)*1000*rootdepth;
else
    AbvFc = 0;
end  
WCadj = InitCond.Tpot+InitCond.Epot-Rain+Runoff-AbvFc;
     
%% Determine irrigation depth (mm/day) to be applied %%
if GrowingSeason == true
    % Update growth stage if it is first day of a growing season
    if NewCond.DAP == 1
        NewCond.GrowthStage = 1;
    end
    % Run irrigation depth calculation
    switch IrrMngt.IrrMethod
        case 0 % Rainfed - no irrigation
            Irr = 0;
        case 1 % Irrigation - soil moisture
            % Get soil moisture target for current growth stage
            SMT = IrrMngt.SMT(NewCond.GrowthStage);
            % Determine threshold to initiate irrigation
            IrrThr = (1-SMT/100)*TAW;
            % Adjust depletion for inflows and outflows today
            Dr = Dr+WCadj;
            if Dr < 0
                Dr = 0;
            end
            % Check if depletion exceeds threshold
            if Dr > IrrThr
                % Irrigation will occur
                IrrReq = max(0,Dr);
                % Adjust irrigation requirements for application efficiency
                EffAdj = ((100-IrrMngt.AppEff)+100)/100;
                Irr = IrrReq*EffAdj*IrrMngt.IT;
            else
                % No irrigation
                Irr = 0;
            end
        case 2 % Irrigation - fixed interval
            % Get number of days in growing season so far (subtract 1 so that
            % always irrigate first on day 1 of each growing season)
            nDays = NewCond.DAP-1;
            % Adjust depletion for inflows and outflows today
            Dr = Dr+WCadj;
            if Dr < 0
                Dr = 0;
            end
            if rem(nDays,IrrMngt.IrrInterval) == 0
                % Irrigation occurs
                IrrReq = max(0,Dr);
                % Adjust irrigation requirements for application efficiency
                EffAdj = ((100-IrrMngt.AppEff)+100)/100;
                Irr = IrrReq*EffAdj;
            else
                % No irrigation
                Irr = 0;
            end
        case 3 % Irrigation - pre-defined schedule
            % Get current date
            CurrentDate = AOS_ClockStruct.StepStartTime;
            % Find irrigation value corresponding to current date
            Irr = IrrMngt.IrrigationSch((IrrMngt.IrrigationSch(:,1)==CurrentDate),2);
        case 4 % Irrigation - net irrigation
            % Net irrigation calculation performed after transpiration, so
            % irrigation is zero here
            Irr = 0;
            
        %------- New strategies -------%
        case 5 % Decision Table
            % Adjust depletion for inflows and outflows today
            Dr = Dr+WCadj;
            if Dr < 0, Dr = 0; end
            % Irrigation occurs
            IrrReq = max(0,Dr);
            % Adjust irrigation requirements for application efficiency
            EffAdj = ((100-IrrMngt.AppEff)+100)/100;
            full = IrrReq*EffAdj;
            
            % Get parameters for calculation
            theta = thRZ.Act;
            fc = thRZ.Fc;
            Q0 = NewCond.irr_storage;
            q = NewCond.irrstrg_avail(AOS_ClockStruct.SeasonCounter);
            DV = NewCond.DV(:,NewCond.GrowthStage);
            if thRZ.Act > thRZ.Fc, theta = thRZ.Fc; end % Adjust theta if oversaturated
        
            % Field Capacity threshold
            X0 = 0;
            X1 = DV(1); % subject of optimization
            X2 = 1;

            % Available water storge threshold
            Y0 = 0;
            Y1 = DV(2); % subject of optimization
            Y2 = 1;

            % Decision Table limits
            L1 = DV(3);  % subject of optimization - case wet and few water
            L2 = DV(4);  % subject of optimization - case dry and few water
            L3 = DV(5);  % subject of optimization - case wet and much water
            L4 = DV(6);  % subject of optimization - case dry and much water

            % Decision Table IF Loops  
            if ((fc*X0)<=theta && theta<=(fc*X1) && (Q0*Y0)<=q && q<=(Q0*Y1)) % case dry and few water
                Irr = min((full*L2),q);
            elseif ((fc*X1)<=theta && theta<=(fc*X2) && (Q0*Y0)<=q && q<=(Q0*Y1)) %case wet and few water
                Irr = min((full*L1),q);
            elseif ((fc*X0)<=theta && theta<=(fc*X1) && (Q0*Y1)<=q && q<=(Q0*Y2)) %case dry and much water
                Irr = min((full*L4),q);
            elseif ((fc*X1)<=theta && theta<=(fc*X2) && (Q0*Y1)<=q && q<=(Q0*Y2)) %case wet and much water
                Irr = min((full*L3),q);
            end
            
    end
    
    Irr = min(IrrMngt.MaxIrr,Irr); % Limit irrigation to maximum depth
    if Irr < IrrMngt.MinIrr, Irr = 0; end % Limit irrigation to minimum depth
    
    % Update water storage
    if IrrMngt.IrrMethod == 5, NewCond.irrstrg_avail(AOS_ClockStruct.SeasonCounter) = q-Irr; end
    
    % Update cumulative irrigation counter for growing season
    NewCond.IrrCum = NewCond.IrrCum+Irr;
elseif GrowingSeason == false
    % No irrigation outside growing season
    Irr = 0;
    NewCond.IrrCum = 0;
end

end
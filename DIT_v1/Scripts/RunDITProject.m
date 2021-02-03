function RunDITProject(conf)
% RunDITProject runs a single Deficit Irrigation Toolbox (DIT) project and processes/saves the outputs.
%
% FUNCTION:
%	function RunDITProject(conf)
%
% INPUT:
%	- "conf" are the configurations of your DIT project
%
% DEVELOPER:
%	Chair of Hydrology at TU Dresden(Germany):
%	- Prof. Dr. Niels Schütze
%	- Oleksandr Mialyk
%
% ABBREVIATIONS:
%	- "AOS" is AquaCrop-OS model
%	- "CWPF" is Crop-Water Production Function
%	- "DV" is Decision Variables
%	- "GS" is Growing Season
%	- "SWB" is Soil-Water Balance model

%% 1. Initialization
DIT_Initialization;

%% 2. Run DIT
tic; % Start the timer
nSims = length(conf.sims); % Number of simulations

DISPLAY = true;    %If DISPLAY is false no output is shown in command window

% Show welcome messages
if DISPLAY
    disp('================ DIT START ================');
    disp(['Project: ' conf.project]);
    disp(['Number of simulations: ' num2str(nSims)]);
    disp(['Simulation period: ' num2str(year(conf.SimStart)) '-' num2str(year(conf.SimEnd)) ' (' num2str(year(conf.SimEnd) - year(conf.SimStart)) ' y)']);
    disp(['Calculation mode: ' conf.calc_mode_name{conf.calc_mode}]);
    disp(['Crop model: ' conf.crop.model_full_names{conf.crop.model}]);
end

if conf.crop.model == 2
    switch conf.combination
        case 2
            disp('Soil variability: Many soil hydrology files for each growing season');
            disp(['Number of soil hydrology files: ' num2str(conf.soil.num)]);
        case 3
            disp('Soil variability: Several random soil hydrology files for each growing season');
            disp(['Number of random soil hydrology files: ' num2str(conf.soil.rand) ' out of ' num2str(conf.soil.num)]);
    end
end

if DISPLAY
    disp(['Crop name: ' conf.crop.name]);
    disp(['Irrigation strategy: ' conf.strategies{conf.irr.strategy}]); disp(' ');
    disp('Progress:');
end

% Run simulations
for i = 1:nSims
    if DISPLAY, disp([' - Simulation ' num2str(i) ':']); end 
    conf.sim = i;
    if conf.cwpf, conf.irr.qmax = conf.irr.cwpf_steps(i); end % Define qmax for the current CWPF step
    if ismember(conf.irr.strategy, [5:7]) % Optimization strategies
        conf.save_data = false; conf.show_log = 0; % Deactivate some parameters before the optimization
        if DISPLAY, disp('   ~ Optimizing the irrigation...'); end
        if conf.irr.strategy == 7 % Optimize irrigation schedule with GET-OPTIS
            DV_opt = GET_OPTIS(conf, weatherDB); 
        elseif conf.irr.strategy == 5 || conf.irr.strategy == 6 % Decision table
            DV_opt = DecisionTable(conf, weatherDB);
        end
        DVs(i,:) = DV_opt; % Save the optimal solution
        if numel(DV_opt) == 24, DV_opt = reshape(DV_opt, 6, 4); end 
        conf.DV = DV_opt; % Apply the optimal solution
        conf.save_data = save_data; conf.show_log = 1; % Activate the deactivated parameters
    end
    if DISPLAY, disp('   ~ Calculating crop yields...'); end
    % Run the crop model
    [Y(i,:), P(i,:), ET(i,:), Irr(i,:)] = feval(crop_func, conf, weatherDB);
end

%% 3. Plot and Save Figures
if conf.viz
    disp(' - Plotting figures...');
    if conf.crop.model == 1, Y = Y*100; end % Convert yields to % for SWB
    
    % Plot climate as monthly quantiles when more than 3 years were used
    if(year(conf.SimEnd) - year(conf.SimStart) >= 3), DIT_PlotWeather(conf); end 
    
    % Plot CWPF and supplementary graphs
    if conf.cwpf        
        DIT_PlotCWPF(Y,conf); % Plot CWPF
        
        % Plot a group histogram
        if conf.hist_same_xaxis  % Use same x-axis scale to each graph
            conf.xaxis = [floor(min(Y(:)))*0.9 round(max(Y(:)))*1.1];
        end
        if numel(Y(1,:)) > 3, DIT_PlotGroupHistogram(Y, conf); end
        
        % Plot histogram and Scatter plot
        for s = 1:numel(Y(:,1))
            conf.sim = s;
            if conf.cwpf, conf.irr.qmax = conf.irr.cwpf_steps(s); end
            if conf.save_data, conf.plots_visable = 0; end
            if numel(Y(s,:)) > 3, DIT_PlotHistogram(Y(s,:), conf); end % Yields' histogram
            DIT_PlotScatter(reshape(Y(s,:),[],1), reshape(Irr(s,:),[],1), conf); % Yields' scatter plot
        end
    else   
        if conf.hist_same_xaxis  % Use same x-axis scale to each graph
            conf.xaxis = [floor(min(Y(:)))*0.9 round(max(Y(:)))*1.1];
        end
        
        if numel(Y) > 3, DIT_PlotHistogram(Y,conf); end % Yields' histogram
        DIT_PlotScatter(reshape(Y,[],1), reshape(Irr,[],1), conf); % Yields' scatter plot
    end
end

%% 4. Finish simulation
% Save data
cur_time = round(toc,1); % Check the time passed
if conf.save_data
    if DISPLAY, disp(' - Saving results...'); end
    save([conf.FileLocOut '/' conf.saveas '_final.mat'],... % Save .mat file with annual results
            'Y', 'Irr', 'P', 'ET', 'conf', 'DVs', 'cur_time');
end

% Display the closing messages
if cur_time > 100, cur_time = [num2str(round(cur_time/60,1)) ' min']; else, cur_time = [num2str(cur_time) ' sec']; end
if DISPLAY, disp([' - Successful finish (', cur_time, ')']); disp(' '); end
if conf.save_data, disp(['You can find results in DIT/' conf.FileLocOut '/']);end
if DISPLAY, disp('================ DIT END ================'); end

end
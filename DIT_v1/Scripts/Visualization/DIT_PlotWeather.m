function DIT_PlotWeather(conf)
% DIT_PlotWeather plots statistical analysis of AquaCropOS climate file(.txt)
%
% FUNCTION:
%	function DIT_PlotWeather(conf)
%
% INPUT:
%	- "conf" are the configurations of your DIT project

%% Initialization
% Read weather data inputs
fileID = fopen(strcat(conf.FileLocIn, '/', conf.crop.climate_file)); % Open the file
if fileID == -1, error('Weather input file not found\n'); end
Data = textscan(fileID, '%f %f %f %f %f %f %f', 'delimiter', '\t', 'headerlines', 2); % Load data
Tmin = Data{1,4}; Tmax = Data{1,5}; P = Data{1,6}; ET = Data{1,7};
Dates = datenum(Data{1,3}, Data{1,2}, Data{1,1}); % Convert dates to serial date format
fclose(fileID);

% Find start and finish dates
first_year = year(conf.SimStart); last_year = year(conf.SimEnd);
num_years = last_year - first_year;
if num_years < 3, warning('Not enough years to plot weather quantiles'); return; end
gs_start = datetime([num2str(first_year) '/' conf.crop.SeedingDate], 'InputFormat', 'yyyy/dd/MM');
gs_end = datetime([num2str(first_year) '/' conf.crop.HarvestDate], 'InputFormat', 'yyyy/dd/MM');

% Transform to monthly values
x = [];
for m = 1:12
    x = [x datetime(first_year,m,1)];
    for y = 1:num_years
        cur_year = first_year + y - 1;
        StartDate = datenum(cur_year, m, 1); % First day of the month
        EndDate = datenum(cur_year, m, eomday(cur_year,m)); % Last day of the month
        StartRow = find(Dates==StartDate);
        EndRow = find(Dates==EndDate);
        
        % Get monthly values
        mTmin(y,m) = mean(Tmin(StartRow:EndRow));
        mTmax(y,m) = mean(Tmax(StartRow:EndRow));
        mP(y,m) = sum(P(StartRow:EndRow));
        mET(y,m) = sum(ET(StartRow:EndRow));
    end
end
x = [x datetime(first_year+1,1,1)];

%% Plot weather quantiles
color = [[0 0.5 0]; [0.6 0.1 0.1]; [0 0 0.7]];
fig = figure('Name', 'Weather summary', 'PaperUnits', 'points', 'Position', [0 0 800 600], 'Color', [1 1 1]);
for p = 1:3 % Plot three graphs P,ET,T
    subplot(3,1,p);
    switch p
        case 1 % Temperature
            plot_title = ['Temperature (' num2str(num_years+1) ' years)'];
            y_title = 'C°';
            y1 = mean(mTmax); y3 = mean(mTmin); y2 = mean([mTmax;mTmin]);
        case 2 % Evaporation
            plot_title = ['Evaporation (' num2str(num_years+1) ' years)'];
            y_title = 'mm';
            y1 = quantile(mET,0.9); y2 = quantile(mET,0.5); y3 = quantile(mET,0.1);            
        case 3 % Precipitation
            plot_title = ['Precipitation (' num2str(num_years+1) ' years)'];
            y_title = 'mm';
            y1 = quantile(mP,0.9); y2 = quantile(mP,0.5); y3 = quantile(mP,0.1);   
    end
    
    % Plot climatic statistics
    y1 = [y1 y1(1)]; y2 = [y2 y2(1)]; y3 = [y3 y3(1)];
    fill([x fliplr(x)], [y1 fliplr(y3)], [0.7 0.7 0.7], 'EdgeColor','k', 'EdgeAlpha',0.1, 'FaceAlpha',0.5); hold on;
    f1 = plot(x, y1, 'LineStyle','--', 'Color',color(p,:), 'LineWidth',0.7);
    f2 = plot(x, y2, '-o', 'Color',color(p,:), 'LineWidth',0.7);
    f3 = plot(x, y3, 'LineStyle',':', 'Color',color(p,:), 'LineWidth',0.7);
    yax = ylim;
    if ismember(p, [2 3])
        ymax = max([quantile(mET,0.9) quantile(mP,0.9)]);
        yax(2) = ceil(ymax/90) * 100;
    end
    if yax(1) >= 0, ylim([0 yax(2)]); end
    % Add growing season area
    if gs_start > gs_end 
    	f4 = fill([datetime(first_year,1,1) datetime(first_year,1,1) gs_end gs_end], [ylim fliplr(ylim)], [0.9 0.9 0],...
                'EdgeColor','k', 'EdgeAlpha',0.1, 'FaceAlpha',0.2); 
        fill([gs_start gs_start datetime(first_year,12,31) datetime(first_year,12,31)], [ylim fliplr(ylim)], [0.9 0.9 0],...
                'EdgeColor','k', 'EdgeAlpha',0.1, 'FaceAlpha',0.2);
    else
    	f4 = fill([gs_start gs_start gs_end gs_end], [ylim fliplr(ylim)], [0.9 0.9 0],...
                'EdgeColor','k','EdgeAlpha',0.1,'FaceAlpha',0.2);
    end
    uistack(f4,'bottom');
    
    % Add descriptions and styling
    title(plot_title, 'Interpreter', 'none');
    ylabel(y_title);
    yticks(0 : round(yax(2))/4 : yax(2));
    xticks(datetime(first_year,1,1) + calmonths(0:12));
    xticklabels({'Jan' 'Feb' 'Mar' 'Apr' 'May' 'Jun' 'Jul' 'Aug' 'Sep' 'Oct' 'Nov' 'Dec' 'Jan'});
    grid on;
    
    % Add legend
    if p == 1
        legend([f4,f1,f2,f3],'Growing season','Average Tmax','Mean','Average Tmin',...
                'Location','eastoutside');
    else
        legend([f4,f1,f2,f3],'Growing season','10% quantile','50% quantile','90% quantile',...
                'Location','eastoutside');
    end
end  

%% Save plot
if conf.save_data
    save_as = [conf.FileLocOut '/' conf.saveas '_WeatherQuants.' conf.fig_format];
    saveas(fig, save_as);
%     f = getframe(fig); % For scientific journals
%     colormap(f.colormap)
%     imwrite(f.cdata, [conf.FileLocOut '/' conf.saveas '_WeatherQuants.tif'], 'Resolution',300, 'RowsPerStrip',16, 'Compression','jpeg');
end

end
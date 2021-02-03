function DIT_PlotGroupHistogram(Y, conf)
% DIT_PlotGroupHistogram plots together histograms of multiple DIT results. 
%
% FUNCTION:
%	function DIT_PlotGroupHistogram(Y, conf)
%
% INPUT:
%	- "Y" are the crop yields
%	- "conf" are the configurations of your DIT project

%% Create plot
% Calculate the height of the figure
n2 = 3; n1 = ceil(numel(Y(:,1))/n2);
fig_height = 100 + n1*200;

% Create the figure
fig = figure('Name','Group Histogram', 'PaperUnits','points', 'Position',[0 0 900 fig_height], 'Color',[1 1 1]); hold on;
title([conf.project ': ' conf.crop.name ' with ' conf.strategies{conf.irr.strategy}], 'Interpreter', 'none');

% Iterate irrigation storages
for s = 1:numel(Y(:,1))
    h1 = subplot(n1, n2, s);
    y = Y(s,:);
    f1 = histogram(y, 'Normalization','probability', 'FaceAlpha',1, 'FaceColor',[0 0.7 0]);
    while f1.NumBins < 3, morebins(f1); end

    % Add descriptions and styling
    grid on;
    ylabel('Probability');
    title([num2str(conf.irr.cwpf_steps(s)) 'mm']);
    if conf.crop.model == 1, yield_units = '%'; else, yield_units = 'ton/ha'; end
    xlabel(['Dry yield [' yield_units ']']);
    if conf.hist_same_xaxis && sum(conf.xaxis) ~= 0, xlim(conf.xaxis); end % Set same x-axis scale to each graph
    box on;
    ax = gca;
    ax.XRuler.Axle.LineWidth = 1.5;
    ax.YRuler.Axle.LineWidth = 1.5;
    
    % Statistics
    if isnan(skewness(y)), skew = '0'; else, skew = num2str(round(skewness(y),2)); end
    str = {['Number of points: ' num2str(length(y))],...
            ['Mean value: ' num2str(round(mean(y),2)) ' ' yield_units],...
            ['Skewness: ' skew],...
            ['SD: ' num2str(round(std(y),2))]};   
    xl = xlim; 
    xPos = xl(1) + diff(xl) / 50;
    ylim([0 1]);
    yl = ylim; 
    text(xPos, yl(2), str, 'Parent', h1, 'FontSize', 8, 'VerticalAlignment', 'top');
end

%% Save plot
if conf.save_data
    save_as = [conf.FileLocOut '/' conf.saveas '_' char(conf.crop.model_names(conf.crop.model)) '_GroupHistorgam.' conf.fig_format];
    saveas(fig, save_as);
%     f = getframe(fig); % For scientific journals
%     colormap(f.colormap)
%     imwrite(f.cdata, [conf.FileLocOut '/' conf.saveas '_' char(conf.crop.model_names(conf.crop.model)) '_GroupHistorgam.tif'], 'Resolution',300, 'RowsPerStrip',16, 'Compression','jpeg');
end

end
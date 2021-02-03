function DIT_PlotHistogram(Y, conf)
% DIT_PlotHistogram plots the historgam of crop yields.
%
% FUNCTION:
%	function DIT_PlotHistogram(Y, conf)
%
% INPUT:
%	- "Y" are the crop yields
%	- "conf" are the configurations of your DIT project

%% Create plot
if numel(Y) < 3, warning('Not enough growing seasons to plot historgam'); return; end
fig_name = ['Histogram (' num2str(conf.irr.qmax) ' mm)'];
if conf.plots_visable
    fig = figure('Name',fig_name, 'PaperUnits','points', 'Position',[0 0 conf.fig_size], 'Color',[1 1 1]); hold on;
else
    fig = figure('Name',fig_name, 'PaperUnits','points', 'Position',[0 0 conf.fig_size], 'Color',[1 1 1], 'visible','off'); hold on;
end
f1 = histogram(Y, 'Normalization','probability', 'FaceAlpha',1, 'FaceColor',[0 0.7 0]);
while f1.NumBins < 4, morebins(f1); end

% Add descriptions and styling
grid on;
title([conf.strategies{conf.irr.strategy}], 'Interpreter', 'none');
ylabel('Probability');
if conf.crop.model == 1, yield_units = '%'; else, yield_units = 'ton/ha'; end
xlabel(['Dry yield [' yield_units ']']);
if conf.hist_same_xaxis && sum(conf.xaxis) ~= 0, xlim(conf.xaxis); end % Set same x-axis scale to each graph
box on;
ax = gca;
ax.XRuler.Axle.LineWidth = 1.5;
ax.YRuler.Axle.LineWidth = 1.5;

% Statistics
if isnan(skewness(Y)), skew = '0'; else, skew = num2str(round(skewness(Y),2)); end
str = {['Number of points: ' num2str(numel(Y))],...
        ['Mean value: ' num2str(round(mean(Y),2)) ' ' yield_units],...
        ['Skewness: ' skew],...
        ['SD: ' num2str(round(std(Y),2))]}; 
xl = xlim; 
xPos = xl(1) + diff(xl) / 50;
ylim([0 1]);
yl = ylim;
text(xPos, yl(2), str, 'FontSize', 9, 'VerticalAlignment', 'top');

%% Save plot
if conf.save_data
    save_as = [char(conf.save_path(conf.sim)) '_' char(conf.crop.model_names(conf.crop.model)) '_Historgam.' conf.fig_format];
    saveas(fig, save_as);
%     f = getframe(fig);  % For scientific journals
%     colormap(f.colormap)
%     imwrite(f.cdata, [char(conf.save_path(conf.sim)) '_' char(conf.crop.model_names(conf.crop.model)) '_Historgam.tif'], 'Resolution',300, 'RowsPerStrip',16, 'Compression','jpeg');
end

end
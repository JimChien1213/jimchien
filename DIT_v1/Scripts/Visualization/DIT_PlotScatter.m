function DIT_PlotScatter(Y, Irr, conf)
% DIT_PlotScatter plots the scatter diagram of crop yields.
%
% FUNCTION:
%	function DIT_PlotScatter(Y, Irr, conf)
%
% INPUT:
%	- "Y" are the crop yields
%	- "Irr" are the actual irrigated volumes [mm]
%	- "conf" are the configurations of your DIT project

%% Create plot
fig_name = ['Scatter (' num2str(conf.irr.qmax) ' mm)'];
if conf.plots_visable
    fig = figure('Name',fig_name, 'PaperUnits','points', 'Position',[0 0 conf.fig_size], 'Color',[1 1 1]); hold on;
else
    fig = figure('Name',fig_name, 'PaperUnits','points', 'Position',[0 0 conf.fig_size], 'Color',[1 1 1], 'visible','off'); hold on;
end
scatter(Irr, Y, 'filled', 'MarkerFaceColor',[0 0.7 0], 'MarkerEdgeColor',[0 0 0]);

% Add descriptions and styling
grid on;
title([conf.strategies{conf.irr.strategy}], 'Interpreter', 'none');
set(get(gca,'XLabel'), 'String', 'Total irrigated water [mm]');
if conf.crop.model == 1, yield_units = '%'; else, yield_units = 'ton/ha'; end
set(get(gca,'YLabel'), 'String', ['Dry yield [' yield_units ']']);
box on;
ax = gca;
ax.XRuler.Axle.LineWidth = 1.5;
ax.YRuler.Axle.LineWidth = 1.5;

% Statistics
str = {['Number of points: ' num2str(numel(Y))],...
        ['Mean value: ' num2str(round(mean(Y),2)) ' ' yield_units],...
        ['SD: ' num2str(round(std(Y),2))]}; 
xl = xlim; 
xPos = xl(1) + diff(xl) / 50;
yl = ylim;
text(xPos, yl(2), str, 'FontSize', 9, 'VerticalAlignment', 'top');

%% Save plot
if conf.save_data
    save_as = [char(conf.save_path(conf.sim)) '_' char(conf.crop.model_names(conf.crop.model)) '_Scatter.' conf.fig_format];
    saveas(fig, save_as);
%     f = getframe(fig); % For scientific journals
%     colormap(f.colormap)
%     imwrite(f.cdata, [char(conf.save_path(conf.sim)) '_' char(conf.crop.model_names(conf.crop.model)) '_Scatter.tif'], 'Resolution',300, 'RowsPerStrip',16, 'Compression','jpeg');
end

end
function DIT_PlotCWPF(Y, conf)
% DIT_PlotCWPF plots Crop-Water Production Function (CWPF)
% with 10%, 50% and 90% quantiles.
%
% FUNCTION:
%	function DIT_PlotCWPF(Y, conf)
%
% INPUT:
%	- "Y" are the crop yields [t/ha]
%	- "conf" are the configurations of your DIT project

%% Data validation
if numel(Y) < 6, warning('Yields array is too small to plot proper CWPF'); end % 3 points x 2 irrigation volumes = 6

%% Generate the data
x1 = conf.irr.cwpf_steps; % Irrigation storages
y1 = quantile(Y, 0.1, 2)'; % 10% quantile
y2 = quantile(Y, 0.5, 2)'; % 50% quantile
y3 = quantile(Y, 0.9, 2)'; % 90% quantile

%% Create plot
color = [[0 0.5 0]; [0.6 0.1 0.1]; [0 0 0.7]; [0.3 0.3 0.3]];
fig = figure('Name','CWPF', 'PaperUnits','points', 'Position',[0 0 800 400], 'Color',[1 1 1]); hold on;
fill([x1 fliplr(x1)], [y1 fliplr(y3)], [0.7 0.7 0.7], 'EdgeColor','k', 'EdgeAlpha',0.1, 'FaceAlpha',0.4);
f1 = plot(x1, y1, '-o', 'Color',color(2,:), 'LineWidth',1);
%f2 = errorbar(x1,y2,y2-min(Y,[],2)',max(Y,[],2)'-y2,[],[],'-o','Color',color(1,:));
f2 = plot(x1, y2, '-o', 'Color',color(1,:), 'LineWidth',1);
f3 = plot(x1, y3, '-o', 'Color',color(3,:), 'LineWidth',1);

% Add descriptions and styling
grid on;
title('CWPF', 'Interpreter', 'none');
numpoints = '';
if conf.combination == 1
    numpoints = [' of ' num2str(size(Y,2)) ' year(s)']; % Add the number of years
end

lgd = legend([f3,f2,f1], ['10% quantile' numpoints], ['50% quantile' numpoints], ['90% quantile' numpoints],...
                            'Location','eastoutside');
title(lgd,'Legend');
set(get(gca,'XLabel'), 'String', 'Irrigation storage [mm]');
if conf.crop.model == 1, yield_units = '%'; else, yield_units = 't/ha'; end
set(get(gca,'YLabel'), 'String', ['Dry yield [' yield_units ']']);

%% Save plot
if conf.save_data
    save_as = [conf.FileLocOut '/' conf.saveas '_CWPF.' conf.fig_format];
    saveas(fig, save_as);
%     f = getframe(fig);  % For scientific journals
%     colormap(f.colormap)
%     imwrite(f.cdata, [conf.FileLocOut '/' conf.saveas '_CWPF.tif'], 'Resolution',300, 'RowsPerStrip',16, 'Compression','jpeg');

end

end
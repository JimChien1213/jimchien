%% Description:
% DIT_DefaultParams adds default settings to your project.
% The script should be ONLY changed if you:
% - Add new part of the code;
% - Want to change the names, e.g. models or strategies.

%% Constant parameters
conf.units = 'mm'; % Must be same as in input files ([mm] is recommended)


%% ---- DO NOT CHANGE ----
% Operational variables
[conf.sim, conf.AOS.soil_texture_file, conf.AOS.soil_GW_file,  conf.cwpf] = deal(0);
[conf.plots_visable, conf.show_log] = deal(1);
conf.FileLocOut = '/';
conf.strategies = {'No irrigation(rainfed)','Full irrigation','Full irrigation with thresholds',...
                    'Constant irrigation','Optimized deficit irrigation with dDecision Table',...
                    'Optimized deficit irrigation with Decision Table(4 phenological stages)',...
                    'Optimized deficit irrigation with GET-OPTIS','Defined irrigation schedule','Defined Decision Table'};
conf.crop.model_names = {'SWB', 'AOS'};
conf.crop.model_full_names = {'Soil-Water Balance', 'AquaCrop-OS v5.0a'};
conf.calc_mode_name = {'Standard', 'Parallel'};
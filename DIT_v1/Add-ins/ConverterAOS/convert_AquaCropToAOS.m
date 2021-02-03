%% Convert AquaCrop to AquaCropOS
% The script to transform AquaCrop files into AquaCrop-OS format. It can convert the next files:
%
% .ETo, .PLU, .TMP into climatic timeseries;
% .SOL into the soil hydrology file and soil profile;
% .SW0 into the initial soil moisture file.
%
% Delevoped by Oleksandr Mialyk (TU Dresden, 2018)

%% 1. Initialization
conv_folder = 'Add-ins/ConverterAOS';
addpath(genpath(conv_folder));

project_name = 'Eradu'; % This name is used to create the outputs
start_date = datetime(2010,01,01); % of climatic data

conv_climate = 1; % Convert climatic data if 1
    ET = 'Eradu.ETo';
    P = 'Eradu.PLU';
    T = 'Eradu.TMP';
    
conv_soil = 1; % Convert soil data if 1
    initial_moisture = 'Eradu_2010.SW0';
    soil = 'Eradu.SOL';
    numComp = 12; dZ = 0.1; % default values of AquaCrop (number of soil compartments and dZ step size[mm])

%% 2. Convert climatic data
if conv_climate
    % Read data
    ET = read_AquaCropData([conv_folder '/Input/' ET],'=========');
    P = read_AquaCropData([conv_folder '/Input/' P],'=========');
    T = read_AquaCropData([conv_folder '/Input/' T],'=========');

    % Create climate file
    fileID = fopen(string([conv_folder '/Output/climate_' project_name '.txt']), 'w');
    fprintf(fileID,'%%%% ---------- Weather input time-series for AquaCropOS ---------- %%%%\r\n');
    fprintf(fileID,'%%%% Day	Month	Year	MinTemp	MaxTemp	Precipitation	ReferenceET %%%%\r\n');
    cur_day = start_date;
    day_num = datenum(start_date);
    for d = 1:length(ET)
        if d>1, fprintf(fileID, '\r\n'); end
        fprintf(fileID,'%i	%i	%i	%.1f	%.1f	%.1f	%.1f',...
        day(cur_day),month(cur_day),year(cur_day),T(d,1),T(d,2),P(d),ET(d));
        day_num = day_num+1;
        cur_day = datetime(day_num,'ConvertFrom','datenum');
    end
    fclose(fileID);
end

%% 3. Convert soil data
if conv_soil
    % Read data
    soil = read_AquaCropData([conv_folder '/Input/' soil],'------------');
    initial_moisture = read_AquaCropData([conv_folder '/Input/' initial_moisture],'=========');
    
    % Create soil hydrology file
    fileID = fopen(string([conv_folder '/Output/AOS_SoilHydrology_' project_name '.txt']), 'w');
    fprintf(fileID,'%%%% ---------- Soil hydraulic properties for AquaCropOS ---------- %%%%\r\n');
    fprintf(fileID,'%%%% LayerNo  LayerThickness(m)  thS(m3/m3)    thFC(m3/m3)  thWP(m3/m3)   Ksat(mm/day) %%%%\r\n');

    for i = 1:size(soil,1)
        if i>1, fprintf(fileID,'\r\n'); end
        fprintf(fileID, '%i	%.2f	%.2f	%.2f	%.2f	%.2f', i, soil(i,1), soil(i,2)/100, soil(i,3)/100, soil(i,4)/100, soil(i,5));
    end
    fclose(fileID);
    
    % Create soil profile file
    fileID = fopen(string([conv_folder '/Output/AOS_SoilProfile_' project_name '.txt']), 'w');
    fprintf(fileID,'%%%% ---------- Soil profile discretisation for AquaCropOS ---------- %%%%\r\n');
    fprintf(fileID,'%%%% CompartmentNo	Thickness(m)	LayerNo %%%%\r\n');
    
    layers = round(cumsum(soil(:,1)),2);
    num_layers = length(layers);
    curZ = 0;
    
    for i = 1:numComp
        if numComp-i == 1, dZ = (layers(end) - curZ)/2; end
        curZ = round(curZ + dZ,2);
        cur_layer = find(curZ <= layers,1);
        if i>1, fprintf(fileID,'\r\n'); end
        fprintf(fileID, '%i	%.2f	%i', i, dZ, cur_layer);    
    end
    fclose(fileID);
    
    % Create initial soil moisture file
    fileID = fopen(string([conv_folder '/Output/AOS_InitialWaterContent_' project_name '.txt']), 'w');
    fprintf(fileID,'%%%% ---------- Initial soil water content for AquaCropOS ---------- %%%%\r\n');
    fprintf(fileID,"%%%% Type of value ('Prop' (i.e. WP/FC/SAT), 'Num' (i.e. XXX m3/m3), 'Pct' (i.e. %% TAW)) %%%%\r\nNum\r\n");
    fprintf(fileID,"%%%% Method ('Depth': Inteprolate depth points; 'Layer': Constant value for each soil layer) %%%%\r\nLayer\r\n");
    fprintf(fileID,['%%%% Number of input points (NOTE: Must be at least one point per soil layer) %%%%\r\n' num2str(size(initial_moisture,1)) '\r\n']);
    fprintf(fileID,'%%%% Input data points (Depth/Layer   Value) %%%%\r\n');
    
    for i = 1:size(initial_moisture,1)
        if i>1, fprintf(fileID,'\r\n'); end
        fprintf(fileID, '%.2f	%.3f', i, initial_moisture(i,2)/100);
    end
    fclose(fileID);
end
disp(['Success, you can find results in ' conv_folder '/Output']);

function extr_data = read_AquaCropData(filename,start_line)
    % INPUT:
    % 1) filename - name of the file for convertion
    % 2) start_line - line after which MATLAB is reading the data
    %
    % OUTPUT:
    % extr_data - array with the extracted data
    
    fileID = fopen(filename,'r');
    if fileID == -1, fprintf('Error - input file is not found'); end
    tline = fgetl(fileID);
    start_reading = 0; i = 1;
    while ischar(tline)
        if start_reading
            temp = textscan(tline,'%s');
            for v = 1:numel(temp{1})
                extr_data(i,v) = str2double(temp{1}{v});
            end
            i = i+1;
        end
        if contains(tline,start_line), start_reading = 1; end
        tline = fgetl(fileID);
    end
    fclose(fileID);
end
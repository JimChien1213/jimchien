%% Prepare the climate file for DIT
% ConvertWeather converts climatic time-series into DIT format.
% Available formats:
%   - dwf
%
% Delevoped by Oleksandr Mialyk (TU Dresden, 2018)

%% Set up
cliconv_path = 'Add-ins/ConverterClimate';
cli_file = 'Montpellier_LARS_500'; % Name of the input file
cli_format = 'dwf'; % Format of the input file
save_as = 'Montpellier1y'; % Name of the output file
starting_year = 2000; % Start from this year 
years_num = 1; % Number of years to include

%% Convert climate
switch cli_format
    case 'dwf'
        convertDWF(cliconv_path, [cli_file '.' cli_format], save_as, starting_year, 1, years_num);
end

disp(['Success, you can find results in ' cliconv_path '/Output'])

%% Additional functions
function convertDWF(cliconv_path, filename, project_name, first_year, start, finish)
    wg_data = load([cliconv_path '/Input/' filename],' -ascii ');
    
    % Reshape data
    [l_r, l_c] = size(wg_data);
    nr = l_r/365;
    d3 = reshape(wg_data,l_r/nr,nr,l_c); % 3D array
    
    d3et = reshape(d3(:,:,7),365,nr);% ET
    d3et = d3et(1:365,:);
    d3tmin = reshape(d3(:,:,8),365,nr);% Tmin + Tmax
    d3tmin = d3tmin(1:365,:);
    d3tmax = reshape(d3(:,:,9),365,nr);
    d3tmax = d3tmax(1:365,:);
    d3prec = reshape(d3(:,:,6),365,nr); % Precipitation
    d3prec = d3prec(1:365,:);
    %d3rad = reshape(d3(:,:,4),365,nr); % Radiation
    %d3rad = d3rad(1:365,:);
    
    % Write file
    f1 = fopen(strjoin([cliconv_path '/Output/', string(project_name), '.txt'],''), 'w');
    fprintf(f1,'%%%% ---------- Weather input time-series for DIT ---------- %%%%\r\n');
    fprintf(f1,'%%%% Day	Month	Year	MinTemp	MaxTemp	Precipitation	ReferenceET %%%%\r\n');
    
    day_num = datenum(first_year,1,1);
    cur_day = datetime(day_num,'ConvertFrom','datenum');
    for y = start:finish
        for d = 1:365
        	fprintf(f1,'%i	%i	%i	%.1f	%.1f	%.1f	%.1f\r\n',...
                    day(cur_day),month(cur_day),year(cur_day),d3tmin(d,y),d3tmax(d,y),d3prec(d,y),d3et(d,y));
            day_num = day_num+1;
            cur_day = datetime(day_num,'ConvertFrom','datenum');
            if(mod(year(cur_day),4) == 0 &&...
                    month(cur_day) == 2 && day(cur_day) == 29) % Add same line for the leap years
                fprintf(f1,'%i	%i	%i	%.1f	%.1f	%.1f	%.1f\r\n',...
                        day(cur_day),month(cur_day),year(cur_day),d3tmin(d,y),d3tmax(d,y),d3prec(d,y),d3et(d,y));
                day_num = day_num+1;
                cur_day = datetime(day_num,'ConvertFrom','datenum');
            end
        end  
    end
    
    fclose(f1);
    
    %%Save
end
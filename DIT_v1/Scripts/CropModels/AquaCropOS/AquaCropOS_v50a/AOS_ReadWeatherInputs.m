function weatherDB = AOS_ReadWeatherInputs(conf)
% AOS_ReadWeatherInputs reads and processes climatic time-series for AquaCrop-OS.
% The script is based on the code provided by Tim Foster (http://aquacropos.com/).
%
% FUNCTION:
%	function weatherDB = AOS_ReadWeatherInputs(conf)
%
% INPUT:
%	- "conf" are the configurations of your DIT project
%
% OUTPUT:
%	- "weatherDB" is database with climatic time-series
%
% DEVELOPER:
%	Chair of Hydrology at TU Dresden(Germany):
%	- Oleksandr Mialyk
%
% REFERENCE:
%	- Foster, T., Brozovi, N., Butler, A.P., Neale, C.M.U., Raes, D., Steduto, P., Fereres, E., Hsiao, T.C.:
%	  AquaCrop-OS: An open source version of FAO’s crop water productivity model. Agricultural Water Management,
%	  Vol. 181, S. 18-22, 2017, doi:10.1016/j.agwat.2016.11.015

%% 1. Initialization
%% Declare global variables %%
%global AOS_ClockStruct

%% Read input file location %%
%Location = FileLocation.Input;

%% Read weather data inputs %%
% Open file
%filename = FileLocation.WeatherFilename;
%fileID = fopen(strcat(Location,filename));
fileID = fopen([conf.FileLocIn '/' conf.crop.climate_file]); % NEW CODE
if fileID == -1
    % Can't find text file defining weather inputs
    % Throw error message
    fprintf(2,'Error - Weather input file not found\n');
end

% Load data in
Data = textscan(fileID,'%f %f %f %f %f %f %f','delimiter','\t','headerlines',2);
fclose(fileID);

%% Convert dates to serial date format %%
Dates = datenum(Data{1,3},Data{1,2},Data{1,1});

%% Extract data %%
Tmin = Data{1,4};
Tmax = Data{1,5};
P = Data{1,6};
Et0 = Data{1,7};

%% Extract data for simulation period %%
% Find start and end dates
%StartDate = AOS_ClockStruct.SimulationStartDate;
%EndDate = AOS_ClockStruct.SimulationEndDate;

StartDate = datenum(conf.SimStart); % NEW CODE
EndDate = datenum(conf.SimEnd); % NEW CODE
StartRow = find(Dates==StartDate);
EndRow = find(Dates==EndDate);

% Store data for simulation period
weatherDB = [Dates(StartRow:EndRow),Tmin(StartRow:EndRow),...
    Tmax(StartRow:EndRow),P(StartRow:EndRow),...
    Et0(StartRow:EndRow)];

end
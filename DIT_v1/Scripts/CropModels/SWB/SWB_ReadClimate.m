function [weatherDB, conf] = SWB_ReadClimate(conf)
% SWB_ReadClimate reads and processes climatic time-series for a Soil-Water Balance Model(SWB).
%
% FUNCTION:
%	function [weatherDB, conf] = SWB_ReadClimate(conf)
%
% INPUT:
%	- "conf" are the configurations of your DIT project
%
% OUTPUT:
%	- "weatherDB" is the database with climatic time-series

%% 1. Initialization
% Open file
fileID = fopen([conf.FileLocIn '/' conf.crop.climate_file]);
if fileID == -1
    fprintf(2, 'Error - Weather input file not found');
end

%% 2. Read the data
% Load
Data = textscan(fileID,'%f %f %f %f %f %f %f', 'delimiter','\t', 'headerlines',2);
fclose(fileID);

% Convert dates to the serial date format
Dates = datenum(Data{1,3} ,Data{1,2}, Data{1,1});

% Extract
P = Data{1,6};
PET = Data{1,7};

% Extract the data for simulation period
if ~any(ismember(Dates, datenum(conf.SimStart)))
    warning('Starting date of your simulation is readjusted to fit the climatic data')
    conf.SimStart = datetime(Dates(1), 'ConvertFrom', 'datenum');
end
if ~any(ismember(Dates, datenum(conf.SimEnd)))
    warning('Ending date of your simulation is readjusted to fit the climatic data')
    conf.SimEnd = datetime(Dates(end), 'ConvertFrom', 'datenum');
end
StartDate = datenum(conf.SimStart);
EndDate = datenum(conf.SimEnd);
StartRow = find(Dates == StartDate);
EndRow = find(Dates == EndDate);

% Store the data for simulation period
weatherDB = [Dates(StartRow:EndRow), P(StartRow:EndRow), PET(StartRow:EndRow)];

end 
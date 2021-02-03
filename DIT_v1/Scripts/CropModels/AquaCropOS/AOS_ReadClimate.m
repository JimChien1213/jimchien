function [weatherDB, conf] = AOS_ReadClimate(conf)
% AOS_ReadClimate reads and processes climatic time-series for AquaCrop-OS(AOS).
% This script is a modified version of AOS_ReadWeatherInputs.m by Tim Foster(2017).
%
% FUNCTION:
%	function [weatherDB, conf] = AOS_ReadClimate(conf)
%
% INPUT:
%	- "conf" are the configurations of your DIT project
%
% OUTPUT:
%	- "weatherDB" is the database with climatic time-series
%	- "conf" are the adjusted configurations of your DIT project
%
% REFERENCE:
%	- Foster, T., Brozovi, N., Butler, A.P., Neale, C.M.U., Raes, D., Steduto, P., Fereres, E., Hsiao, T.C.:
%	  AquaCrop-OS: An open source version of FAO’s crop water productivity model. Agricultural Water Management,
%	  Vol. 181, S. 18-22, 2017. DOI:10.1016/j.agwat.2016.11.015 (http://aquacropos.com/)

%% 1. Initialization
% Open file
fileID = fopen([conf.FileLocIn '/' conf.crop.climate_file]);
if fileID == -1
    fprintf(2,'Error - Weather input file not found');
end

%% 2. Read the data
% Load
Data = textscan(fileID, '%f %f %f %f %f %f %f', 'delimiter','\t', 'headerlines',2);
fclose(fileID);

% Convert dates to the serial date format
Dates = datenum(Data{1,3} ,Data{1,2}, Data{1,1});

% Extract
Tmin = Data{1,4};
Tmax = Data{1,5};
P = Data{1,6};
Et0 = Data{1,7};

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
weatherDB = [Dates(StartRow:EndRow), Tmin(StartRow:EndRow),...
            Tmax(StartRow:EndRow), P(StartRow:EndRow),...
            Et0(StartRow:EndRow)];

end
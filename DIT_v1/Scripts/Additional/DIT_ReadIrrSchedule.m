function irr_schedule = DIT_ReadIrrSchedule(loc)
% DIT_ReadIrrSchedule reads an irrigation schedule produced by DIT.
%
% FUNCTION:
%	function irr_schedule = DIT_ReadIrrSchedule(loc)
%
% INPUT:
%	- "loc" is the location of the irrigation schedule
%
% OUTPUT:
%	- "irr_schedule" is the irrigation schedule

% Open the file
fileID = fopen(loc,'r');
if fileID == -1
    error('Irrigation schedule is not found, please check conf.irr.schedule_file');
end
tline = fgetl(fileID);

% Read the file
start_reading = 0; i = 1;
while ischar(tline)
    if start_reading
        temp = textscan(tline,'%s\t%s');
        irr_schedule(i,1) = str2num(cell2mat(temp{1}));
        irr_schedule(i,2) = str2double(cell2mat(temp{2}));
        i = i+1;
    end
    if contains(tline,'Water [mm]'), start_reading = 1; end % Check when to start reading
    tline = fgetl(fileID);
end
fclose(fileID);
    
end
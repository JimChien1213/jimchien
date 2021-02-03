function irr_dvs = DIT_ReadDecisionTable(loc)
% DIT_ReadDecisionTable reads a Decision Table produced by DIT.
%
% FUNCTION:
%	function irr_dvs = DIT_ReadDecisionTable(loc)
%
% INPUT:
%	- "loc" is the location of the Decision Table
%
% OUTPUT:
%	- "irr_dvs" is the Decision Table

% Open the file
fileID = fopen(loc,'r');
if fileID == -1
    error('Decision Table is not found, please check conf.irr.dectab_file');
end
tline = fgetl(fileID);

% Read the file
start_reading = 0; i = 1;
while ischar(tline)
    if start_reading
        temp = textscan(tline,'%s\t%s\t%s\t%s\t%s\t%s');
        irr_dvs(i,1) = str2double(cell2mat(temp{1}));
        irr_dvs(i,2) = str2double(cell2mat(temp{2}));
        irr_dvs(i,3) = str2double(cell2mat(temp{3}));
        irr_dvs(i,4) = str2double(cell2mat(temp{4}));
        irr_dvs(i,5) = str2double(cell2mat(temp{5}));
        irr_dvs(i,6) = str2double(cell2mat(temp{6}));
        i = i+1;
    end
    if contains(tline,'L2	L3	L4'), start_reading = 1; end % Check when to start reading
    tline = fgetl(fileID);
end
fclose(fileID);

end
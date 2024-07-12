%% importMA

clear all
close all

pat = '~/Desktop/conorWallace/ma/!_Subject_CW064_Experiment_Tethered_3_EtOH_15_Sac_0.2_DEP_Group.Cohort_6.txt';

% Open the file for reading
fileID = fopen(pat, 'r');

% Read all elements from the file into a cell array
dataCellArray = textscan(fileID, '%s', 'Delimiter', '\n');

% Close the file
fclose(fileID);

% Extract the cell array from the output of textscan
dataCellArray = dataCellArray{1};
maData.header = dataCellArray(1:13);

j=1;
for i=14:numel(dataCellArray);
    spl = regexp(dataCellArray{i},':','once','split');  % split the text
    spl = strtrim(spl);                                 % get rid of leading white space
    if isempty(str2num(spl{1}));                        % is the first col a letter?
        varIdx(j) = i; 
        varCol(j) = spl(1); j=j+1;   
    end;
    reData{i,1} = str2num(spl{1});
    reData{i,2} = str2num(spl{2});
end;

for i = 1:numel(varIdx);
    if i~=numel(varIdx);
        maData.(varCol{i}) = cell2mat(reData(varIdx(i):varIdx(i+1),:));
    else;
        maData.(varCol{i}) = cell2mat(reData(varIdx(i):end,:));
    end;
end;

clearvars -except maData

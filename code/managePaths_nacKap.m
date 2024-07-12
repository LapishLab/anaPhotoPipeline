function [patSave, patData, vars, DirList, metaData] =  managePaths_nacKap(excludeList, main_pat)

% This code manages the paths to the data, code, and results. In addition,
% it manages the exclusion of data sets from the analysis. 

%% Set path of where to save the data
patSave = [ main_pat '/res/'];

%% Set the path where the data is located. must be in a folder called data
patData = [main_pat '/data/'];

%% Set DirList and metaData 
load([patData '/metaData.mat']); % Set metadata variables
vars     = metaData(1,:);
DirList  = metaData(2:end,1);
metaData = metaData(2:end,1:end);

%% Exclude animals/datasets
if ~isempty(excludeList);
    for i =1:length(excludeList);
% %         k1{i} = find(strncmp(excludeList{i},DirList(:,1),5)==1); % get rid of an entire animal
        k1{i} = find(strcmp(excludeList{i},DirList(:,1))==1); % get rid of data set
    end;
    k2 = 1:length(DirList);
    disp('Ignoring the following data sets:...'); DirList(cell2mat(k1'))
    k  = setdiff(k2, cell2mat(k1'));
    DirList  = DirList(k,:);
    metaData = metaData(k,:);
end;
%% plotSpontStats_nacKap.m
function [] = plotSpontStats_nacKap(fs, lLim, uLim, sexSel, depVar, saveData, savePlot, excludeList, main_pat)

%% Variables
% sexSel = select sex you want to plot can be 'Male' 'Female' 'All'
% depVar = select DV you want to plot can be 'Prominence'; % 'Amplitude','Width','Prominence','Frequency (Hz)'
% saveData = if 1 will save DATA to patSave (TODO where is patSave set?)
% savePlot = if 1 will save FIGURE to patSave (TODO where is patSave set?)

% %% script block (ignore this block)
% clear all
% close all
% sexSel = 'Male'; % 'Male' 'Female' 'All'
% depVar = 'Prominence'; % 'Amplitude','Width','Prominence','Frequency (Hz)'
% saveData = 0;
% savePlot = 1;

%% Load Data
load res_getSpontDA_nacKap.mat; % get results of getSpontDa*  

%% Set the paths to data, code, results, data to exclude
[patSave, patData, vars, DirList, metaData] = managePaths_nacKap(excludeList, main_pat);

%% Set internral Variables
xA      = [-lLim:1/fs:uLim];
numCond = 3; % number of conditions to graph (leave hard coded for now)

figure();
%% Split into conditions, cycle through IV's
for j = 1:numCond;
    x1 = unique(metaData(:,1+j));
    fdx = @(x) ~isempty(x);
    k = cellfun(fdx, x1);
    var_c1 = x1(k);

    for i =1:length(var_c1);
        % Choose sex
        switch sexSel
            case 'All'
                kp = find(strcmp(var_c1{i},metaData(:,1+j))==1);
            case 'Female'
                cond = find(strcmp(var_c1{i},metaData(:,1+j))==1);
                sex  = find(strcmp("Female",metaData(:,5))==1);
                kp   = intersect(cond,sex,'stable');
            case 'Male'
                cond = find(strcmp(var_c1{i},metaData(:,1+j))==1);
                sex  = find(strcmp("Male",metaData(:,5))==1);
                kp   = intersect(cond,sex,'stable');
        end
        % Get DV
        switch depVar
            case 'Amplitude'
                a_cell = spontStats.a(kp);
            case 'Width'
                a_cell = spontStats.w(kp);
            case 'Prominence'
                a_cell = spontStats.p(kp);
            case 'Frequency (Hz)'
                a_cell = spontStats.f(kp);
        end
        a_sessMn{i} = cell2mat(cellfun(@(x) median(x), a_cell, UniformOutput=false));
        dataSetList{i,1} = DirList(kp);
    end;


    m = cell2mat(cellfun(@(x) mean(x), a_sessMn, UniformOutput=false));
    s = cell2mat(cellfun(@(x) std(x)./sqrt(size(x,2)), a_sessMn, UniformOutput=false));
    for i = 1:length(a_sessMn);sz{i} = i*ones(size(a_sessMn{i})); end;
    subplot(1,numCond,j)
    bar(m,'FaceColor', [0.75 0.75 0.75]); hold on;
    errorbar(m,s,'r.','MarkerSize',25,"LineWidth",0.8); hold on;
    xV = cell2mat(sz)';
    asm = cell2mat(a_sessMn)';
    scatter(xV,asm,'ko');hold on;
    xlim([0 3])
    xlabel('Treatment');
    ylabel(depVar);
    set(gca,'XTick',[1 2],'XTickLabel',var_c1);
    title(sexSel)

    %% Write data for plotting
    if saveData == 1;
        allData{j}.vars  = var_c1;
        allData{j}.mn    = m;
        allData{j}.sd    = s;
        allData{j}.sex   = sexSel;
        allData{j}.indPt = [xV asm];
        allData{j}.dsList = dataSetList;
        save([patSave 'transStats_' sexSel '_' depVar '.mat'],"allData",'-mat')
    end;


end
if savePlot == 1;
    saveas(gcf,[patSave '/Timeseries_' sexSel '_' depVar],'pdf')
end


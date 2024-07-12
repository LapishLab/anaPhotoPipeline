%% plotSpontDa_nacKap
function [] = plotSpontDa_nacKap(fs, lLim, uLim, sexSel, saveData, savePlot, excludeList, main_pat)

%% Variables
% sexSel = select sex you want to plot can be 'Male' 'Female' 'All'
% saveData = if 1 will save DATA to patSave. 
% savePlot = if 1 will save FIGURE to patSave. 
% patSave is defined in managePaths_nacKap.m

%% Load Data
load res_getSpontDA_nacKap.mat; % get results of getSpontDa*

%% Set the paths to data, code, results, data to exclude
[patSave, patData, vars, DirList, metaData] = managePaths_nacKap(excludeList, main_pat);

%% Set internral Variables
xA      = [-lLim:1/fs:uLim];
numCond = 3; % number of conditions to graph (leave hard coded for now)

% spont = cellfun(@(x) mean(x),spont,'UniformOutput',false); % Takes mean over session prior to graphing

figure();
%% Split into conditions
for j = 1:numCond;
    x1 = unique(metaData(:,1+j));
    fdx = @(x) ~isempty(x);
    k = cellfun(fdx, x1);
    var_c1 = x1(k);

    for i =1:length(var_c1);
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
        df{i} = length(kp);
        c1{i} = cell2mat(clnSpont(kp)'); %% Can get problems here for data with no transients. 
    end;

    mn = []; sd =[];
    subplot(1,numCond,j)
    clr = {'r';'b'};
    for i=1:length(c1);
        %         shadedErrorBar(xA,mean(c1{i}),std(c1{i})./sqrt(df{i}),'lineProps',clr{i}); hold on;
        shadedErrorBar(xA,mean(c1{i}),std(c1{i})./sqrt(size(c1{i},1)),'lineProps',clr{i}); hold on;
        xlabel('Time (sec)');
        ylabel('DA signal (df/f)')
        mn = [mn; mean(c1{i})];
        sd = [sd; std(c1{i})./sqrt(size(c1{i},1))];
    end
    legend(var_c1,'location','northoutside')
    title(sexSel)

    %% Write data for plotting
    if saveData == 1;
        allData{j}.vars = var_c1;
        allData{j}.mn   = mn;
        allData{j}.sd   = sd;
        allData{j}.sex  = sexSel;
        save([patSave 'rawData_' sexSel '.mat'],"allData",'-mat')
    end;

end

if savePlot==1;
    saveas(gcf,[patSave '/Timeseries_' sexSel],'pdf')
end;

% % % Ignore diagnostic below
% %% Plotting number of transients excluded around Fver
% % sz = cell2mat(cellfun(@(x) size(x,1),allSpont,"UniformOutput",false));
% % perct = (nmExcl./sz);
% % [~,idx] = sort(perct);
% % figure()
% % subplot(121)
% % bar(perct(idx));
% % xlabel('Sorted data set');
% % ylabel('Percent of excluded transients')
% % subplot(122)
% % bar(sz(idx));
% % xlabel('Sorted data set by number excluded');
% % ylabel('Number of spontaneous transients');
% % 

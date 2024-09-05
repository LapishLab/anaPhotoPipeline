%% anaPhotoData_nacKap
% routine to run through all preprocessing and analysis steps of photometery data

%% TODO
% 1. Might need a quick way to make excludeList.  For a set of parameters, 
% run through the traces and find data sets with no spontaneous transients. 

clear all
close all

%% managePaths_nacKap.m 
% Each routine calls managePaths_nacKap. This code manages the paths to 
% the data, code, and results. In addition, it manages the exclusion of 
% data sets from the analysis. 

%% Put the path to your parent directory here. Leave as 'pwd' if you want it done automatically
main_pat = pwd; % or the old fashioned way --> '/Users/clapish/Library/CloudStorage/OneDrive-IndianaUniversity/INIAstress_CSAC/connerWallace/NAc_SpontaneousKappaProject/curated/';

%% Adding files importers and anaysis code
addpath(genpath([main_pat '/code/']));

%% List the data sets to exclude here. Are you SURE they are spelled correctly?
excludeList = {'CS009_L-NAC-240311-121730'}; % To exclude nothing = {};

%% Import data 
disp('************** Importing data **************')
% Set variables for importing
zs          = 0;        % zscore prior to detrending = 1; % <-- can interfere with detrending. Leave as no. 
detrendData = 1;        % detrend the data? Yes=1; Always leave as yes. 
getFver     = 1;        % Get lick or lever press data? Yes=1;
subIso      = 0;        % Subtract off isosbestic signal? Yes=1;
clipTime    = 10;       % Remove saturated part at the begining of the signal? 
                        % If ~=0 remove saturated part at start (fs*10). Units
                        % are seconds.
getPhotoData_nacKap(zs, detrendData, getFver, subIso, clipTime, excludeList, main_pat)

%% Get spontaneous transients
disp('************** Getting spontaneous transients **************') 
%% Set varibales for dLight
fs = 1.0173e+03;        % sample frequency
lLim = 1;               % Time to pull before peak of spont transient in sec
uLim = 1;               % Time to pull after peak of spont transient in sec
minPkHeight = 1;        % in zscores. Threshold for peak height. 
minPkDist = round(fs/4);% Peaks have to be at least this separated. 
minPkProm = 2;          % Prominence. I found that 2 was good for this (ccl).  
zspont = 0;             % zscore the peak heights following the detection stage. 
getSpontDA_nacKap(fs, lLim, uLim, minPkHeight, minPkDist, minPkProm, excludeList, main_pat, zspont)

%% Plot spontaneous data timeseries 
disp('************** Plotting spontaneous timeseries **************') 
sexSel      = 'All';    % What sex do you want to plot? 'Male' 'Female' 'All'
saveData    = 1;        % Save the mean+/- sem of the data? Yes=1;
savePlot    = 1;        % Save the plot? Yes=1;
plotSpontDa_nacKap(fs, lLim, uLim, sexSel, saveData, savePlot, excludeList, main_pat)

%% Plot statistics of the spontaneous transients.
disp('************** Plotting spontaneous stats **************') 
depVar = 'Amplitude';   % 'Amplitude','Width','Prominence','Frequency (Hz)'
plotSpontStats_nacKap(fs, lLim, uLim, sexSel, depVar, saveData, savePlot, excludeList, main_pat)

%% ccl 
function [compiledData] = mkCompiledData

clear all
close all

%% Put the path to your parent directory here. Leave as 'pwd' if you want it done automatically
main_pat = pwd; % or the old fashioned way --> '/Users/clapish/Library/CloudStorage/OneDrive-IndianaUniversity/INIAstress_CSAC/connerWallace/NAc_SpontaneousKappaProject/curated/';

%% Adding files importers and anaysis code
addpath(genpath([main_pat '/code/']));

%% List the data sets to exclude here. Are you SURE they are spelled correctly?
excludeList = {'CS009_L-NAC-240311-121730'}; % To exclude nothing = {};

%% Get the metaData
[patSave, patData, vars, DirList, metaData] =  managePaths_nacKap(excludeList, main_pat);

%% Load indiv traces
load res/getSpontDA_nacKap.mat


compiledData = [metaData clnSpont' spontStats.a' spontStats.w' spontStats.p' spontStats.f'];

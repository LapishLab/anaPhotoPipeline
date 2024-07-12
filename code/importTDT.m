function photoData = importTDT(photoPath,getFver)

%% %TODO: Find a way to disambuguate licks from lever presses. Confusing. 

% addpath(genpath('~/Desktop/conorWallace/TDTMatlabSDK'))
% photoData = TDTbin2mat('~/Desktop/conorWallace/CW064_L-NAC-230111-174156');

photoData = TDTbin2mat(photoPath);
photoData.iso     = photoData.streams.x405A.data; % Isobestic control 
photoData.gc      = photoData.streams.x465A.data; % GCaMP
photoData.fs      = photoData.streams.x465A.fs;
photoData.tm      = 1/photoData.fs:1/photoData.fs:length(photoData.gc)/photoData.fs;

%% Getting env and behav variables

% Get sessions start (Eart)
try
    photoData.start = photoData.epocs.Eart.onset;
catch
    disp(['No Eart: ' photoPath])
    photoData.start  = nan;
end

%Get Fver (licks, lever presses)
if getFver == 1;
    try
        photoData.Fver  = photoData.epocs.Fver.onset;
    catch
        disp(['No Fver: ' photoPath])
        photoData.Fver  = nan;
    end
end 



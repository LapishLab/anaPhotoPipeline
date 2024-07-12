function [] = getPhotoData_nacKap(zs, detrendData, getFver, subIso, clipTime,excludeList, main_pat)

%% Track variables. They stay with the data, so you know what was done. 
preprocessingVars.zs          = zs;          % zscore = 1; % <-- can interfere with detrending
preprocessingVars.detrendData = detrendData; % detrend the data
preprocessingVars.getFver     = getFver;     % Get lick or lever press data?
preprocessingVars.subIso      = subIso;      % Subtract off isosbestic signal
preprocessingVars.clipTime    = clipTime;   % Remove saturated part at the begining of the signal. 
                                % If ~=0 remove saturated part at start (fs*10). Units
                                % are seconds.

%% %% Geting paths, retrieving metadata, excluding data
[patSave, patData, vars, DirList, metaData] =  managePaths_nacKap(excludeList,main_pat);

for XX = 1:size(DirList,1);
    photoData   = importTDT([patData DirList{XX,1}], getFver);
    iso     = photoData.iso;    % Isobestic control
    gc      = photoData.gc;     % GCaMP
    fs      = photoData.fs;     % Sample frequency
    tm      = photoData.tm;     % Time of recording
    st      = photoData.start;   % Start of behavior (Eart)  
    if getFver == 1; FverTm = photoData.Fver; end; % Licks & lever press are coded as Fver    

    clipStart = round(fs*clipTime);  % remove saturated part at the begining of the signa.

    %% Subtracting off isosbestic signal?
    if subIso == 1;
        nGC = gc-iso; disp('Subtracting off isosbestic');
    else
        nGC = gc; disp('NOT subtracting off isosbestic');
    end

    %% Zscore?, create delta F/F signal
    if zs==1;
        s = zscore(nGC-mean(nGC)/mean(nGC)); %deltaF/F
    else
        s = nGC-mean(nGC)/mean(nGC); %deltaF/F
    end

    %% Get rid of inital saturated signal 
    if clipStart ~= 0;
        s = s(clipStart:end);
    end

    %% Need to detrend data
    if detrendData ==1;
        smth  = smooth(s,fs*100);
        smthS =  s - smth';
    end

    %% put back zeros so time isn't off
    if clipStart ~= 0;
        zr = zeros(1,round(clipStart)-1);
        s = [zr smthS];
    end
    
    %% Collect variables 
    sessSt(XX)   = st;       % Start of behavior   
    Fver{XX}     = FverTm;   % Licks and lever presses
    sig{XX}      = s;        % The pre preocessed optical signal (DLight)      

    disp([num2str(XX) '/' num2str(size(DirList,1))]);

end

clearvars -except sig Fver sessSt preprocessingVars

preprocessingVars.time = char(datetime('now','TimeZone','local','Format','yyyy-MM-dd''T''HH:mmXXX'));

saveFileName = ['res', filesep, 'getPhotoData_nacKap.mat'];
disp(['Saving: ', saveFileName])
save(saveFileName)
% !ls -lh res_getPhotoData_nacKap.mat
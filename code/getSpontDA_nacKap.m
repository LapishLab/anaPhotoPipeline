function [] = getSpontDA_nacKap(fs, lLim, uLim, minPkHeight, minPkDist, minPkProm, excludeList, main_pat, zspont)

%% Geting paths, retrieving metadata, excluding data
[patSave, patData, vars, DirList, metaData] =  managePaths_nacKap(excludeList, main_pat);

%% Load data
sourceMat = ['res', filesep, 'getPhotoData_nacKap.mat'];
load(sourceMat)

%% track preprocessing varibales for dLight
preprocessingVars.fs            = fs;
preprocessingVars.lLim          = lLim;
preprocessingVars.uLim          = uLim;
preprocessingVars.minPkHeight   = minPkHeight;
preprocessingVars.minPkDist     = minPkDist;
preprocessingVars.minPkProm     = minPkProm;

%% Loop through each dataset and get spont peaks. 
for XX = 1:size(DirList,1);

    %% get signal and time
    s = sig{XX};
    xA = 1/fs:1/fs:length(s)*(1/fs);

    %% Get all DA transients
    % use find peaks to get tranisents (zscore 2.6 was threshold in Conner preprint)
    zs = zscore(s);
    [z_amp,locs,wid,prm] = findpeaks(zs, "MinPeakHeight", minPkHeight, "MinPeakDistance", minPkDist, "MinPeakProminence",minPkProm);
    
    %% zscore signal for analysis?
    if zspont == 1;
        amp = z_amp;         % This takes the zscored amplitude of the detrended signal. 
    else
        amp = s(locs);          % This takes the amplitude of the detrended signal, not zscore.
    end

    %% Skip this block if no peaks are found 
    if ~isempty(locs)
        %% Take all transients
        for i = 1:length(locs);
            try % using try here b/c some of the transients are within the lim of the start/stop of session
                allHld(i,:) = s(locs(i)-round(lLim*fs):locs(i)+round(uLim*fs));
            end
        end;

        %% separate lever press and sess start transients
        evt = [sessSt(XX) Fver{XX}'];  % get event times
        %     k_lk = find(histc(evt,xA)==1); % Can be used to index evt for viz.

        %% eliminate transients near lever presses
        tmTrans = xA(locs);
        for i=1:length(tmTrans);
            kp(i) = isempty(find(evt > tmTrans(i)-lLim & evt <= tmTrans(i)+uLim));
        end;
        
        %% Removing stats near lever presses
        clean_amp = amp(kp==1);
        clean_wid = wid(kp==1);
        clean_prm = prm(kp==1);
        clean_locs = locs(kp==1); 
        tmTrans = xA(clean_locs);
        clean_frq = 1./diff(tmTrans);     % Gets the frequency of the peaks in Hz
        clear kp
        
        %% Get traces excluding those near lever presses
        for i = 1:length(clean_locs);
            try % using try here b/c some of the transients are within the lim of the start/stop of session
                if zspont == 1;
                    clnHld(i,:) = zs(clean_locs(i)-round(lLim*fs):clean_locs(i)+round(uLim*fs));
                else
                    clnHld(i,:) = s(clean_locs(i)-round(lLim*fs):clean_locs(i)+round(uLim*fs));
                end
            end
        end;

        nmEx = size(allHld,1) - size(clnHld,1); %% Keeps a record of the number of excluded transients in clnHld
    
    else; % Set variables to nan if no transients found
%         amp = nan; wid = nan; prm = nan; frq = nan; nmEx = nan;
%         clnHld = nan; 
%         allHld = nan;
        error(['No spontaneous transients found for: ' DirList{XX} '. Add this dataset to excludeList and rerun'])
    end
    
    spontStats.a{XX} = clean_amp;
    spontStats.w{XX} = clean_wid;
    spontStats.p{XX} = clean_prm;
    spontStats.f{XX} = clean_frq;
    nmExcl(XX)       = nmEx;
    clnSpont{XX}     = clnHld; clear clnHld
    allSpont{XX}     = allHld; clear allHld
end

saveFileName = ['res', filesep, 'getSpontDA_nacKap.mat'];
save(saveFileName,"clnSpont","allSpont","spontStats","nmExcl","sourceMat","preprocessingVars")

% % %% Diagnostics
% % k_lk = find(histc(evt,xA)==1); % Can be used to index evt for viz.
% % xH = min(s):0.01:max(s);
% % h = hist(s,xH);
% % subplot(131);bar(xH,log10(h));
% % subplot(1,3,2:3)
% % plot(xA,s,'k');hold on;                 % plotting signal
% % plot(xA(locs),s(locs),'ro'); hold on;   % plotting location of transients
% % 
% % plot(xA,s,'k');hold on;                 % plotting signal
% % plot(xA(locs),s(locs),'ro'); hold on;   % plotting location of transients
% % 
% % s1 = sig{90}(1,rm0);
% % plot(xA,s1,'b');hold on;                 % plotting signal
% % plot(xA(locs),s1(locs),'co'); hold on;   % plotting location of transients
% % 
% % figure();
% % x = cell2mat(spont');
% % zx = zscore(x')';
% % subplot(121)
% % imagesc(zx,[-1 1])
% % subplot(122)
% % plot(mean(zx))


%% Looking at unprocessed vs processed signal, I find no evidence of warping by preprocessing.  



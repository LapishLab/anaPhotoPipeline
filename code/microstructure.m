%MICROSTRUCTURE - Grab the microstructure data from lick data
%
%INPUT: -etohlickstart: Column vector of licking startpoints in seconds
%       -etohlickend: Column vector of licking endpoints in seconds
%
%OUTPUT: A struct containing:
    %BOUTNUM: the number of bouts in etohlick, with the start of a bout
    %defined as start_size consecutive licks within start_length seconds of each other and the
    %end of a bout defined as end_size licks within >end_length seconds of each other
    %STRAY_LICK_NUM: the number of stray licks (licks not within a bout)
    %BOUT_SIZE: the number of licks in a bout
    %BOUT_DURATION: the length of time in second of a bout
    %STARTBOUT: list of all the time stamps of bout starts
    %ENDBOUT:list of all the time stamps of the bout ends
    %BOUT_ILI: the length of each interlick interval (time between two licks) in a bout
    %BOUT_LICK_DURATION: Duration of all the licks in each bout
    %IBI: The time in seconds between each bout, should equal boutnum-1
    %STRAY_LICK: list of all the timestamps of the stray licks
    %STRAY_LICK_DURATION: the length of each stray lick in seconds
    %ALL_ILI: column vector of all the ILIs from all the bouts
    %ALL_BOUT_LICK_DURATION: List of the durations of each lick in all the
    %bouts
    %ALL_LICK_DURATION: List of the durations of all the licks in etohlick
    %LICK_DURATION_FILTERED: List of the durations of the licks less than 1
    %second
    %LICK_DURATION_FILTERED_NUM: The number of licks that were filtered out (greater than
    %1 second in duration). Licks weren't actually removed from
    %'All_LICK_DURATION,' a new array of the licks was created
    %FILTERED_LICK: List of timepoints of licks with durations greater than
    %1s
    %MEAN_BOUT_SIZE: Mean of the bout sizes
    %MEAN_BOUT_DURATION: Mean of the bout durations
    %MEAN_IBI: Mean of the IBIs
    %MEAN_BOUT_LICK_DURATION: Mean of the duration of the licks in all the
    %bouts
    %MEAN_ALL_LICK_DURATION: Mean of all the lick durations
    %MEAN_LICK_DURATION_FILTERED: Mean of the duration of all the filtered
    %licks (LICK_DURATION_FILTERED)
    %TOTAL_LICKS_IN_BOUT: Number of licks in all the bouts
    %TOTAL_LICKS: sum of the number of licks in all the bouts and the stray licks,
    %should equal the size of etohlick. Just serves as a test to make sure
    %function is working correctly 
    %TOTAL_LICK_TIMES:timestamps of all the licks (etohlickstart)
%NOTES:
%The ending timepoints of the licks (etohlickend vector) are only used to 
%calculate the lick duration. All other calculations (ex. ILI, IBI) use the
%starting timepoints of the licks (etohlickstart)
%
% Written by Habiba Noamany, July 2018
% 
%
% https://doi.org/10.1126/science.aay1186
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function animal_struct=microstructure(etohlickstart,etohlickend)
etohlick=etohlickstart;
etohend=etohlickend;
if numel(etohlick)~=numel(etohend)
    if numel(etohlick)==numel(etohend)+1
        deltLick=questdlg('The lick start array has one more value than the lick end array, would you like to remove the last lick start value from this analysis?',...
         'Lick array mismatch',...
         'Remove', 'Continue');
        switch deltLick
            case 'Remove'
                etohlick=etohlick(1:end-1);
            case 'Continue'
                fprintf ('Continuing with %d lick onsets and %d lick offsets', (numel(etohlick)),(numel(etohend)));
        end
                
    end
end

%%%%%BOUT DEFIINITION PARAMETERS%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
start_size=3   % Number of licks to start a bout
end_size=2     % Number of licks to end a bout
start_length=1 %Time within start_size to start a bout
end_length=3   %Time within end_size to end a bout
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

animal_struct=...
struct('boutnum',[], ...
'stray_lick_num',[],...
'bout_size',[] ...
,'bout_duration',[],...
'startbout',[],...
'endbout',[],...
'bout_ILI',[],...
'bout_lick_duration',[],...
'IBI',[],...
'stray_lick',[],...
'stray_lick_duration',[],...
'all_ILI',[],...
'all_bout_lick_duration',[],...
'all_lick_duration',[],...
'lick_duration_filtered',[],...
'lick_duration_filtered_num',[],...
'filtered_lick',[],...  
'mean_bout_size',[],...
'mean_bout_duration',[],...
'mean_IBI',[],...
'mean_bout_lick_duration',[],...
'mean_all_lick_duration',[],...
'mean_lick_duration_filtered',[],...
'total_licks_in_bout',[],...
'total_licks',[],...
'total_lick_times',[]) 

animal_struct(1).total_lick_times=vertcat(etohlick);
i_timestamp = 1;
boutnum=0;
counter=0;
stray_lick=0;
%keeps track of stray licks that occur in a group but resets after each
%bout
stray_lick_counter=0;
boutend=0;
%keeps tracks of the total number of stray licks to help with indexing into
%the struct
test_counter=0;
%keeps track of the indices of potential bout starts
newlookarray=[];
%keeps track of the end of a bout, don't need to initialize  a start bout
%array because it's not referenced outside the loop looking for bouts if
%there aren't any bouts, but the end bout array is, to looks for licks
endboutarray=[];
%looping on the time stamp
while i_timestamp <= length(etohlick)-start_size+1 && counter <=length(etohlick)
    counter=counter+1;
    
    %check if the current lick is starting a bout
    if etohlick(i_timestamp+start_size-1)-etohlick(i_timestamp) <= start_length
        stray_lick=0;
        stray_lick_counter=0;
        startbout=i_timestamp;
        %storing the total number of bouts
        boutnum=boutnum+1;
        %store the start of a new bout
        startboutarray(boutnum,1)=etohlick(startbout,1);
        animal_struct(boutnum).startbout=etohlick(startbout,1);
        %look for end of bout defined by two licks within >3
        for i_end=startbout:length(etohlick)-end_size+1
            if etohlick(i_end+end_size-1,1)-etohlick(i_end,1)>end_length;
                boutend=i_end;
                endboutarray(boutnum,1)= etohlick(boutend,1);
                animal_struct(boutnum).endbout=etohlick(boutend,1);
                newlook=boutend+1;
                newlookarray(boutnum,1)=newlook;
                i_timestamp = newlook;
                break
            end
         endboutarray(boutnum,1)=etohlick(end);
         animal_struct(boutnum).endbout=etohlick(end);
        
         i_timestamp=length(etohlick);
        end
     %stray licks   
    elseif etohlick(i_timestamp+start_size-1)-etohlick(i_timestamp) > start_length
        stray_lick=1;
        stray_lick_counter=stray_lick_counter+1;
        test_counter=test_counter+1;
        if boutend ==0
            animal_struct(test_counter).stray_lick=etohlick(i_timestamp,1);
        else
            animal_struct(test_counter).stray_lick=etohlick(boutend+stray_lick_counter,1);
        end
    end
    i_timestamp=i_timestamp+stray_lick
end
%account for stray licks occuring after the end of the last bout and
%another bout isn't possible
if boutend<length(etohlick)&& length(newlookarray) == length(endboutarray)
    test_counter=test_counter+1;
    % the end
    if boutend < i_timestamp && i_timestamp == length(etohlick)
        range=length(etohlick)-boutend-1;
        for i=0:range
            animal_struct(test_counter+i).stray_lick=etohlick(boutend+1+i);
        end
        %more stray licks after end of last bout
    else
        range=length(etohlick)-i_timestamp;
        for i=0:range;
            animal_struct(test_counter+i).stray_lick=etohlick(i_timestamp+i);
        end
    end
end
%rest of the microstructure
%lick duration
%accounts for session ending before the end of the last lick
%(etohend=etohlick-1)
if length(etohend)==length(etohlick)-1;
    all_lick_duration=etohend-etohlick(1:length(etohend));
else
    all_lick_duration=etohend-etohlick;
end
all_stray_licks=vertcat(animal_struct(1:end).stray_lick);
animal_struct(1).all_lick_duration=vertcat(all_lick_duration);

%Creates a new filtered list of lick of durations less than 1s. Doesn't remove the
%actual lick or duration from original
max_lick_duration=1 %Maximum duration for licks, in seconds
lick_duration_filtered=all_lick_duration(all_lick_duration<=max_lick_duration); %lick durations less than 1s
licksout=[];
animal_struct(1).lick_duration_filtered_num=length(all_lick_duration)-length(lick_duration_filtered) ;
for i=1:length(all_lick_duration)
    if all_lick_duration(i,1)<=1
        lickdurationin(i,1)=all_lick_duration(i,1);
    else
        licksout(i,1)=etohlick(i,1);
    end

end
lickdurationin=lickdurationin(lickdurationin~=0);
licksout=licksout(licksout~=0);
animal_struct(1).lick_duration_filtered=lickdurationin;
animal_struct(1).filtered_lick=licksout
for i=1:length(all_stray_licks)
    stray_lick_index=find(etohlick==all_stray_licks(i))
    %accounts for session ending before the end of the last lick
    if length(etohend)==length(etohlick)-1 && stray_lick_index==length(etohlick);
        break
    end
    animal_struct(i).stray_lick_duration=all_lick_duration(stray_lick_index,1);
end
for i=1:boutnum
        %find the index of etoh licks for the begining of a bout
        startbout_index=find(etohlick==startboutarray(i));
       %find the index of etoh licks for the end of a bout
        endbout_index=find(etohlick==endboutarray(i));
        %get the bout submatrix from etoh licks
        bout = etohlick(startbout_index:endbout_index,1);
        ili=diff(bout);
        bout_lick_duration=all_lick_duration(startbout_index:endbout_index,1);
        bout_size=length(bout);
        bout_duration=endboutarray(i)-startboutarray(i);
        animal_struct(i).bout_ILI=ili;
        animal_struct(i).bout_lick_duration=bout_lick_duration;
        animal_struct(i).bout_size=bout_size;
        animal_struct(i).bout_duration=bout_duration;
        if i<= boutnum-1
            ibi=startboutarray(i+1)-endboutarray(i);
            animal_struct(i).IBI=ibi;
        end 
       
end
animal_struct(1).boutnum=boutnum;
all_ili=vertcat(animal_struct(1:boutnum).bout_ILI);
animal_struct(1).all_ILI=all_ili;
all_bout_lick_duration=vertcat(animal_struct(1:boutnum).bout_lick_duration);
animal_struct(1).all_bout_lick_duration=all_bout_lick_duration;
%check that the number of licks in a bout plus the number of stray licks is
%equal to the total number of licks
total=sum(vertcat(animal_struct(1:boutnum).bout_size))+sum(length(vertcat(animal_struct(:).stray_lick)));
animal_struct(1).total_licks=total;
animal_struct(1).stray_lick_num=length(vertcat(animal_struct(1:end).stray_lick));
animal_struct(1).mean_bout_size=mean(vertcat(animal_struct(1:boutnum).bout_size));
animal_struct(1).mean_bout_duration=mean(vertcat(animal_struct(1:boutnum).bout_duration));
animal_struct(1).mean_IBI=mean(vertcat(animal_struct(1:boutnum).IBI));
animal_struct(1).mean_bout_lick_duration=mean(vertcat(animal_struct(1:end).all_bout_lick_duration));
animal_struct(1).mean_lick_duration_filtered=mean(vertcat(animal_struct(1:end).lick_duration_filtered));
animal_struct(1).mean_all_lick_duration=mean(vertcat(animal_struct(1:end).all_lick_duration));
animal_struct(1).total_licks_in_bout=length(vertcat(animal_struct(1:end).all_bout_lick_duration));
end
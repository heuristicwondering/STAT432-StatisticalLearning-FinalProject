% This is to add stimulus label names to each time point (genterated from
% the createROI_timecourse script) for later analysis in R.
% IMPORTANT: Brain volumes are assigned according to their onset.
% -- Example: Brain volume collected at time 6s - 8s, but stimuli 1
%       started at 5s and ended at 7s and stimuli 2 started 7s and ended 9s, 
%       the brain volume will be labelled stimuli 1.
clear all

           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%   Things to change to be relevant to your system  %%%%%%%%%%%%
           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

subjectsIDs = {'112', '116', '117', '119', '120', '131', '133', '135', ...
    '137', '148', '152', '153', '166', '178', '182', '184', '185', ...
    '186', '187', '190', '192', '193', '194', '196'};
sessions = {'affect_1', 'affect_2', 'infant_1', 'infant_2'};

timecourses_topfolder = fullfile('C:','Users','Megan','Documents',...
    'STAT432-StatisticalLearning-FinalProject','data','ROI_timecourses');
stimuli_topfolder = fullfile('C:','Users','Megan','Documents',...
    'STAT432-StatisticalLearning-FinalProject','data','stimuli_timings');

                  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%      Don't touch the code below      %%%%%%%%%%%%%%%%%%
                  %   unless you know what you're doing  %
                  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

TR = 2; % number of seconds between each time point

for thisSubject = subjectsIDs
    for thisSession = sessions
        
        thisTimeCourse = fullfile(timecourses_topfolder, thisSubject{:}, ...
            strcat(thisSubject{:}, '_', thisSession{:}, ... 
            '_AALROImeanTimeCourses.csv'));
        thisStimTiming = fullfile(stimuli_topfolder, thisSubject{:}, ...
            strcat(thisSubject{:}, '_', thisSession{:}, '.mat'));
        
        data = readtable(thisTimeCourse);
        stimuli = load(thisStimTiming); % struct with names, duratations, onsets
        stimuli.offsets = cell(size(stimuli.onsets));
        for i = 1:length(stimuli.onsets) % for readability
            stimuli.offsets{i} = stimuli.onsets{i} + stimuli.durations{i};
        end
        
        % time starts at 0.
        dataTimes = [0:size(data,1)-1]*TR;
        dataLabels = strings(size(dataTimes));
        
        % assigning stim names.
        for i = 1:length(stimuli.onsets)
            theseOnsets = stimuli.onsets{i};
            theseOffsets = stimuli.offsets{i};
            thisStimName = stimuli.names{i};
            stimAssignment = arrayfun(...
                @(t) any((t > theseOnsets) & (t < theseOffsets)), dataTimes);
            dataLabels(stimAssignment) = thisStimName;
        end
        % if no label assigned, label ISI (interstimuli interval)
        dataLabels(arrayfun(@(s) isempty(char(s)), dataLabels)) = 'ISI';
        
        % add labels to data and write back to file
        T = table(dataLabels','VariableNames',{'Stimuli'});
        data = [T,data];
        writetable(data, thisTimeCourse);
    end
end

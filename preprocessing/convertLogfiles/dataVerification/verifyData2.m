% This script is meant to verify that all stimuli/fixation times are
% back-to-back in a given run. i.e. there is no unlabelled time.
% Assumes verifyData.m has been run and does not check that the labelled
% stimuli are withing the scan time. Just makes sure the labelling is
% continuous.

clear
clc

parentdir = fullfile('C:', 'Users', 'Megan', 'Documents', 'MATLAB', ...
    'dataConversion4Heide', 'ev files', filesep); % Path to parent directory of .ev folders

% Assuming each subject folder contains a .txt file of stim onsets
subjdirs = dir(parentdir);
dirIndex = [subjdirs.isdir];
subjdirs = {subjdirs(dirIndex(3:end)).name};
subjdirs = subjdirs(3:end);

% The max time allowed between the offset of a stimuli and the onset of the
% next stimuli.
interStimTolerance = 0;

% Looping through each subject directory
for subj = subjdirs
    stimfile = fullfile(parentdir, subj{:}, [subj{:}, '.txt'] );
    allRunsThisSubj = {}; % All onsets and offsets for all runs
    
    fid = fopen(stimfile);
    tline = fgetl(fid); % Header. (condition,subject,session,onset,duration)
    tline = fgetl(fid);
    while ischar(tline)
        strline = strsplit(tline, ',');
        
        % Extracting data from these sections in the text line
        condition = strline{1};
        sessNum = str2num(strline{3});
        onsets = cellfun( @str2num, strsplit(strline{4}) );
        durations = cellfun( @str2num, strsplit(strline{5}), 'UniformOutput', false );
        durations = cell2mat(durations);
        
        % Gathering onsets and offsets for each run
        if ( all( size(onsets) == size(durations) ) ) || ( numel(durations) == 1 )
            offsets = onsets + durations;
        else
            error('verifyData:sizeMismatch', 'Unexpected size of durations.');
        end
        % Not assuming that the total number of sessions is already known
        % or that they will be given in ascending order.
        onoffsets = [onsets; offsets];
        try
            allRunsThisSubj{sessNum} = [allRunsThisSubj{sessNum}, onoffsets];
        catch ME % Adding empty cells is sessNum out of bounds
            if strcmp(ME.identifier,'MATLAB:badsubscript')
                [numrow, numcol] = size(allRunsThisSubj);
                diff = sessNum - numcol;
                allRunsThisSubj = [allRunsThisSubj, cell(diff, 1)];
                allRunsThisSubj{sessNum} = [allRunsThisSubj{sessNum}, onoffsets];
            else
                rethrow(ME)
            end
        end
        tline = fgetl(fid);
    end
    fclose(fid);
    
    % Checking that the onsets and offsets are continuous
    for i = 1:numel(allRunsThisSubj) 
        [B, I] = sort(allRunsThisSubj{i}(1,:));
        allRunsThisSubj{i} = allRunsThisSubj{i}(:,I); % Sorting onsets/offsets in ascending order
        interStimIntv = allRunsThisSubj{i}(2,1:(end-1)) - allRunsThisSubj{i}(2,2:end); % offset of each stim - onset of the next
        if any(interStimIntv > interStimTolerance)
           warning('verifyData2:InterStimTimeOver', ...
               ['Interstimuli interval found exceeding current',...
               ' tolerance of %d in subject %s, session %i'], interStimIntv, subj{:}, i); 
        end
    end
end
fprintf('done.\n');



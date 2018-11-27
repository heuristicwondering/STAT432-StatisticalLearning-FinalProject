clear
clc

% This script extracts stimuli onsets from event files (.ev type) to csv
% file (saved as .txt). Assumes each subject has their own folder.
%
% If the interstimuli fixation onsets and durations are to be recorded,
% then the script getScanLengths must be run first.
%
%   Written by Megan K. Finnegan
%       heuristicwondering@gmail.com
%       May 26th, 2017

%%% Stuff you should change %%%
%
subjects = {'112', '116', '117', '119', '120', '131', '133', ...
    '135', '137', '148', '152', '153', '166', '178', '179', ...
    '182', '184', '185', '186', '187', '190', '192', '193', ...
    '194', '196'}; % Name of folders containing .ev files

parentdir = fullfile('C:', 'Users', 'Megan', 'Documents', 'MATLAB', ...
    'dataConversion4Heide', 'ev files', filesep); % Path to parent directory of .ev folders

writeFixations = true; % Only use this if you want to record interstimuli info. See note above.
truncateStims = true; % Only use this if you want to truncate stimuli that go beyond the end time of the scan.

%%% Stuff you may need to change %%%
%
% This is the subject ID to write to file. It corresponds to the order in
% the variable 'subjects' above.
subjID = {'1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', ...
    '12', '13', '14', '15', '16', '17', '18', '19', '20', '21', ...
    '22', '23', '24', '25'};

% The following 3 variables are organized to correspond to each other.
% Changing the order of one means you should change the order in the other 2.

% Parts of .ev file names that change. Order is important!
fileSubNames = {'1_own_neg', '1_own_pos', '1_other_neg', '1_other_pos', ...
    '2_own_neg', '2_own_pos', '2_other_neg', '2_other_pos', '1_look_negative', ...
    '1_look_positive', '1_label_negative', '1_label_positive', '2_look_negative', ...
    '2_look_positive', '2_label_negative', '2_label_positive'};

% Session number corresponding to each .ev file. Order is important!
% Note: When calculating interstimuli onsets/durations,  these session 
% numbers also correspond to the index of the recorded scan lengths in the 
% Excel file. This will break if nonconsecutive numberings are use.
sessionNum = [1,1,1,1,2,2,2,2,3,3,3,3,4,4,4,4];

% For assigning labels to data extracted to the .ev files. Order is important!
ev2condition = {'InfOwnNeg','InfOwnPos', 'InfOtherNeg','InfOtherPos', ...
    'InfOwnNeg', 'InfOwnPos', 'InfOtherNeg', 'InfOtherPos', 'EmoLookNeg', ...
    'EmoLookPos', 'EmoLabelNeg', 'EmoLabelPos', 'EmoLookNeg', 'EmoLookPos', ...
    'EmoLabelNeg', 'EmoLabelPos'};

header = 'condition,subject,session,onset,duration';

TR = 2; % Repition time in seconds. Assumed same for all subjects/scans.

%%% Stuff you shouldn't change %%%
%
if writeFixations || truncateStims % Loading scan length data
   if exist('nii_notes.mat')
       load('nii_notes.mat');
   else
      warning('EV2CSV:filenotfound', ['nii_notes.mat not found.', ...
          ' Run getScanLengths.m first. Iterstimuli onsets and', ...
          ' durations will not be recorded and/or stimuli durations not truncated.']);
      writeFixations = false;
   end
end

totNumSessions = numel( unique( sessionNum ) ); % NTS: This will need to be changed to handle nonconsecutive session numbers.

for s = 1:length(subjects) % Going through each subject
    thisSubj = subjects{s};
    allOnsetsAndDurs = cell( totNumSessions , 1 ); % Used to calculate interstimuli onsets and durations
    fid = fopen(fullfile(parentdir, thisSubj, [thisSubj, '.txt']), 'w');
    fprintf(fid, '%s', header);
    
    for f = 1:length(fileSubNames) % Going through each .ev file
        thisFile = [thisSubj, '_', fileSubNames{f}, '.ev'];
        evfile = fullfile(parentdir, thisSubj, thisFile);
        
        if ~exist(evfile)
            warning('ev2csv:missingfile', 'file %s missing. skipping.', thisFile);
            continue;
        end
        
        events = dlmread(evfile);
        
        condition = ev2condition{f};
        id = subjID{s};        
        session = sessionNum(f);
        
        % Triming the events onsets and durations to not exceed the total
        % scan length. Onsets (and their durations) that start after the
        % scan ends are deleted and durations that extend beyond the end of
        % the scan are truncated.
        if truncateStims
            subjIndxCell = strfind( StudyID, thisSubj );
            for i = 1:numel(subjIndxCell)
               if subjIndxCell{i} == 1
                   subjIndx = i;
                   break;
               end
            end
            numVols = scan_lengths(subjIndx, session );
            endTime = numVols * TR; % Ending time in seconds
          
          % Deleting onsets over end time
          [row, col] = find( events(:,1) > endTime );
          if ~isempty( row )
             events(row,:) = [];
          end
          
          % Truncating durations over end time
          offsets = (events(:,1) + events(:,2));
          [row, col] = find( offsets > endTime );
          if ~isempty( row )
              events(row, 2) = endTime - events(row,1);
          end

        end
        
        eventOnsets = strtrim(sprintf('%.3f ', events(:,1)'));
        if size(unique(events(:,2)), 1) > 1 % If not all values are the same
            duration = sprintf(' %.3f', events(:,2));
        else
            duration = sprintf(' %.3f', events(1,2));
        end
        
        if writeFixations % Recording event onsets and durations for this stimuli
            data2Add = [ events(:,1)'; events(:,2)' ]; % onsets; durations
            
            % Finding first empty column in this row.
            frstEmptyColIndx = find( cellfun( @isempty, allOnsetsAndDurs(session, :) ), 1);
            
            if isempty( frstEmptyColIndx ) % If no empty cells, add some.
                emptyCellArr = cell( totNumSessions , 1 );
                allOnsetsAndDurs = [ allOnsetsAndDurs, emptyCellArr ];
                allOnsetsAndDurs(session, end) = {data2Add};
            else
                allOnsetsAndDurs(session, frstEmptyColIndx) = {data2Add};
            end        
        end
        
        % Checks range of event durations to see if any have more than .5s variation.
%         if range(events(:,2)) > .5
%            fprintf('Subject: %s, Condition: %s, Range: %.3f\n',...
%                thisSubj, fileSubNames{f}, range(events(:,2))); 
%         end

        formatSpec = '\n%s,%s,%d,%s,%s';
        fprintf(fid, formatSpec, condition, id, session, eventOnsets, duration);
    end
    
    if writeFixations
       for sess = 1:size(allOnsetsAndDurs,1) % Going through each session
          thisOnsDurs = allOnsetsAndDurs( sess, : );
          thisOnsDurs = cell2mat( thisOnsDurs );
          [~,I] = sort( thisOnsDurs(1,:) ); % Sorting onset times
          thisOnsDurs = [ thisOnsDurs(1,I); thisOnsDurs(2,I);];

          eventOnsets = [];
          duration = [];
          % The first fixation
          curOnset = 0;
          curDur = thisOnsDurs(1,1);
          if curDur > 0
              eventOnsets = [eventOnsets, curOnset];
              duration = [duration, curDur];
          elseif curDur < 0
              warning('EV2CSV:negDuration', sprintf(['The first duration', ...
                  ' is negative (%.3f) for subject %s during session %i'], curDur, thisSubj, sess  ) );
          end
          
          % The fixations in between
          for j = 1:( length( thisOnsDurs ) - 1 )
            curOnset = thisOnsDurs(1,j) + thisOnsDurs(2,j);
            curDur = thisOnsDurs(1,j+1) - curOnset;
            
            if curDur > 0
                eventOnsets = [eventOnsets, curOnset];
                duration = [duration, curDur];
            elseif curDur < 0
                warning('EV2CSV:negDuration', ['Duration i%', ...
                    ' is negative (%.3f) for subject %s during session %i'], curDur, thisSubj, sess  );
            end
          end
          
          % The last fixation
          subjIndxCell = strfind( StudyID, thisSubj );
          for i = 1:numel(subjIndxCell)
              if subjIndxCell{i} == 1
                  subjIndx = i;
                  break;
              end
          end
          numVols = scan_lengths(subjIndx, sess );
          endTime = numVols * TR; % Ending time in seconds
          curOnset = thisOnsDurs(1,end) + thisOnsDurs(2,end);
          curDur = endTime - curOnset;
          
          if curDur > 0
              eventOnsets = [eventOnsets, curOnset];
              duration = [duration, curDur];
          elseif curDur < 0
              warning('EV2CSV:negDuration', ['The last duration', ...
                  ' is negative (%.3f) for subject %s during session %i'], curDur, thisSubj, sess );
          end
          
          eventOnsets = strtrim(sprintf('%.3f ', eventOnsets));
          if size( unique(duration), 1 ) > 1 % If not all values are the same
              duration = sprintf(' %.3f', duration);
          else
              duration = sprintf(' %.3f', duration);
          end
          
          formatSpec = '\n%s,%s,%d,%s,%s';
          fprintf(fid, formatSpec, 'fixation', id, sess, eventOnsets, duration);
          
       end
    end
    
    fclose(fid);
end
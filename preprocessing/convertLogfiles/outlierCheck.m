clear
clc

% This script flags stimuli onsets that may have been incorrectly recorded
% for human inspection. Assumes that EV2CSV has been run.
%
%   Written by Megan K. Finnegan
%       heuristicwondering@gmail.com
%       August 29th, 2017

subjects = {'112', '116', '117', '119', '120', '131', '133', ...
    '135', '137', '148', '152', '153', '166', '178', '179', ...
    '182', '184', '185', '186', '187', '190', '192', '193', ...
    '194', '196'}; % Name of folders containing .ev files

parentdir = fullfile('C:', 'Users', 'Megan', 'Documents', 'MATLAB', ...
    'dataConversion4Heide', 'ev files', filesep); % Path to parent directory

% Parts of .ev file names that change.
fileSubNames = {'1_own_neg', '1_own_pos', '1_other_neg', '1_other_pos', ...
    '2_own_neg', '2_own_pos', '2_other_neg', '2_other_pos', '1_look_negative', ...
    '1_look_positive', '1_label_negative', '1_label_positive', '2_look_negative', ...
    '2_look_positive', '2_label_negative', '2_label_positive'};

% Session number corresponding to each .ev file. Order corresponds to
% fileSubNames.
sessionNum = [1,1,1,1,2,2,2,2,3,3,3,3,4,4,4,4];

TR = 2; % Repition time in seconds. Assumed same for all subjects/scans.

% Loading file that contains info needed to figure out how long scans were.
if exist('nii_notes.mat')
    load('nii_notes.mat');
else
    error('EV2CSV:filenotfound', 'nii_notes.mat not found.');
end

% Opening an error log to record those flagged
errfid = fopen( [parentdir, 'log.txt'], 'w' );

% Matlab will be removing the ability to concatenate mismatched empty
% matrices in future releases. Ignoring this behavior for now.
warning('off', 'MATLAB:catenate:DimensionMismatch');

for thisSubj = subjects % Going through each subject
    thisSubj = char( thisSubj );
    
    for thisSess = unique( sessionNum ) % Going through each session
        sessEvFilesParts = fileSubNames( find( sessionNum == thisSess ) );
        
        for thisEvFilePart =  sessEvFilesParts % Going through each .ev file associated with this session
            thisEvFilePart = char( thisEvFilePart );
            
            evFile = fullfile( parentdir, thisSubj, [thisSubj, '_', thisEvFilePart, '.ev'] );
            
            stimData = dlmread( evFile );
            
            thisEvOnsets = stimData(:,1);
            thisEvDuration = stimData(:,2);
            thisEvOffsets = stimData(:,1) + stimData(:,2);
            
            % Getting the length of this scan.
            subjIndx = find( cell2mat( strfind( StudyID, thisSubj ) ) );
            numVols = scan_lengths( subjIndx, thisSess );
            endTime = numVols * TR; % Ending time in seconds
            
            % Identify elements not in ascending order or onset/offset greater than the length of the scan.
            negdiffs = [ thisEvOnsets(1:(end-1)) - thisEvOnsets(2:end); -1 ]; % Should all be negative.
            posdiffs = [ 1; thisEvOnsets(2:end) - thisEvOnsets(1:(end-1)) ]; % Should all be positive.
            
            % This finds the index of all the numbers that were either
            % less than the number preceeding it or greater that the
            % number following it. Indices reflect value in thisEvOnset.
            outoforderIndx = sort( [ ( find( negdiffs >= 0 ) )', ( find( posdiffs <= 0 ) )' ] );
            
            % All onsets greater than length of scan
            onsetoutofBndsIndx = sort( find( thisEvOnsets > endTime )' );
            
            % All offsets greater than length of scan
            offsetoutofBndsIndx = sort( find( thisEvOffsets > endTime )' );
            
            % Print all flagged stimuli
            if ~isempty(outoforderIndx) || ~isempty(onsetoutofBndsIndx) || ~isempty(offsetoutofBndsIndx)
                fprintf(errfid, 'Errors flagged in file %s\n', [thisSubj, '_', thisEvFilePart, '.ev']);
                for i = 1:numel(outoforderIndx)
                    fprintf(errfid, 'Break in ascending order of onsets on line %i\n', outoforderIndx(i));
                end
                for i = 1:numel(onsetoutofBndsIndx)
                    fprintf(errfid, 'Event onset greater than length of scan on line %i\n', onsetoutofBndsIndx(i));
                end
                for i = 1:numel(offsetoutofBndsIndx)
                    fprintf(errfid, 'Event offset greater than length of scan on line %i\n', offsetoutofBndsIndx(i));
                end
                allflagged = sort( unique( [outoforderIndx, onsetoutofBndsIndx, offsetoutofBndsIndx] ) );
                fprintf(errfid, 'Summary: Check lines ');
                for i = 1:numel(allflagged)
                fprintf(errfid, '%i ', allflagged(i));
                end
                fprintf(errfid, '\n\n');
            end
        end
    end
    
    
    
    %     stimFile = fullfile(parentdir, thisSubj, [thisSubj, '.txt']); % Stim onset file for this subject.
    %
    %     stimData = readtable(stimFile);
    %
    %     for thisSess = unique(stimData{:, 'session'}') % Going through each session
    % %         % Getting the onsets and durations for all stim in this session.
    % %         sessIndx = find(stimData{:, 'session'} == thisSess);
    % %         onsets = stimData{sessIndx, 'onset'};
    % %         onsets = cellfun(@str2num, onsets, 'UniformOutput', false); % Converting from strings to numeric arrays
    % %         durations = stimData{sessIndx, 'duration'};
    % %         onsets = cellfun(@str2num, durations, 'UniformOutput', false); % Converting from strings to numeric arrays
    %
    %         % Getting the length of this scan.
    %         subjIndx = find( cell2mat( strfind( StudyID, thisSubj ) ) );
    %         numVols = scan_lengths( subjIndx, thisSess );
    %         endTime = numVols * TR; % Ending time in seconds
    %     end
    
end

% Cleaning up
warning('on', 'MATLAB:catenate:DimensionMismatch');
fclose( errfid );

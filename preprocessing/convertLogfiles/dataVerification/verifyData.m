% This script is meant to verify the stimuli onset files generated by
% EV2CSV to make sure all stimuli onset/offsets do not exceed scan length

clear
clc

% Table Oregondicomreview imported from Oregon_dicom_review.xlsx
% stim onset files generate with reference to a different excel sheet
% containing scan lengths (20170717_nii_notes.xlsx). This is being used to
% cross check that construction
load('Oregon_dicom_review.mat')

% Getting number of scans for each scan session for this subject
% Assuming that the session order is [1:4] when checking against 
% session numbers specified in the text files.
%volsIndx = cellfun(@isnan, ...
%     table2cell(Oregondicomreview(:,11:24)), ...
%     'UniformOutput', false ); % Finding all the NaN values in the part
                                % of the table that has scan numbers
%notNanIdx = find([volsIndx{:}] == 0); % Finding index of all not NaN

numVols = Oregondicomreview(:, [3,11:15]);

parentdir = fullfile('C:', 'Users', 'Megan', 'Documents', 'MATLAB', ...
    'dataConversion4Heide', 'ev files', filesep); % Path to parent directory of .ev folders

% Assuming each subject folder contains a .txt file of stim onsets
subjdirs = dir(parentdir);
dirIndex = [subjdirs.isdir];
subjdirs = {subjdirs(dirIndex(3:end)).name};
subjdirs = subjdirs(3:end);

% Looping through each subject directory
for subj = subjdirs
    stimfile = fullfile(parentdir, subj{:}, [subj{:}, '.txt'] );
    
    fid = fopen(stimfile);
    tline = fgetl(fid); % Header. (condition,subject,session,onset,duration)
    tline = fgetl(fid);
    while ischar(tline)
        strline = strsplit(tline, ',');
        
        % Extracting data from these sections in the text line
        condition = strline{1};
        sessNum = strline{3};
        onsets = cellfun( @str2num, strsplit(strline{4}) );
        durations = cellfun( @str2num, strsplit(strline{5}), 'UniformOutput', false );
        durations = cell2mat(durations);
        
        % Finding the latest time. Should be in ascending order
        % but not going to assume for now.
        [maxOnst, I] = max(onsets);
        if size(onsets) == size(durations)
            maxOffst = maxOnst + durations(I);
        elseif numel(durations) == 1 % This is because if durations were all the same, only 1 number
            maxOffst = maxOnst + durations;
        else
            error('verifyData:sizeMismatch', 'Unexpected size of durations.');
        end
        
        % Not very efficient, but grabs the scan length in seconds
        scanTime = calcScanTime(sessNum, subj{:}, Oregondicomreview);
        
        % Checking that the last stim offset for this stimuli condition did
        % not exceed the specified scan time
        if maxOffst > scanTime
            wstr = sprintf( ['Max offset longer than scan length: ', ...
                'Subject -- %s, Condition -- %s, Session -- %s\n'],  subj{:}, condition, sessNum);
            warning('verifyData:TimeOver', wstr);
        end
        
        tline = fgetl(fid);
    end
    fclose(fid);
end



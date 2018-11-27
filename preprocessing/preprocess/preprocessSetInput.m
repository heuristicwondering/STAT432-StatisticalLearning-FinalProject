function [ data ] = preprocessSetInput( subjName )
%PREPROCESSSETINPUT Initializes input variables
%   To keep code clean this sets all variables needed to populate the
%   associated batch loader preprocess.

parentdirInput = fullfile( 'C:', 'Users', 'Megan', 'Documents', ...
    'LevinStudy_Analysis_2018', 'RawImaging_Data', 'Raw_NIfTI', subjName );
subdirsSessionInput = {'ep2d_affect_1', 'ep2d_affect_2', 'ep2d_infant_1', ...
    'ep2d_infant_2'};
subdirHiResStrct = 'mprage_MGH_p2';

parentdirOutput = fullfile( 'C:', 'Users', 'Megan', 'Documents',...
    'LevinStudy_Analysis_2018', 'Preprocessed_Data', subjName );
subdirsOutput = {'Slice_Timing_Correction', 'Realign_and_Unwarp' ...
    'Normalization', 'Smoothing'};
subdirsOutputFldNames = {'SliceTimingFldr', 'RealignUnwrpFldr', ...
    'NormlizeFldr', 'SmoothingFldr'}; % For dynamic referencing of output dirs
subsubdirsOutput = {'affect_1', 'affect_2', 'infant_1', 'infant_2'};

% Selecting raw epi images
for i = 1:numel(subdirsSessionInput)
    subDir = subdirsSessionInput{i};
    sessionDir = fullfile( parentdirInput, subDir );
    
    if ~exist( sessionDir, 'dir' )
        error( 'preprocessSetInput:NoSessionDir', ...
            'Raw EPI dir %s for subject %s doesn''t exist.', ...
            subDir, subjName );
    end
    
    if strcmp(subjName, '135');end % Debugging.
    
    listing = dir( sessionDir );
    if numel( listing ) < 3
        error( 'preprocessSetInput:NoEPIfiles', ...
            'No EPI files found for subject %s in dir %s', ...
            subjName, subDir);
    end
    
    for j = 3:numel(listing)
        data.rawEPI{i}{j-2,1} = fullfile( listing(j).folder, listing(j).name );
    end
end

% Selecting high resolution structural images
highresVolDir = fullfile( parentdirInput, subdirHiResStrct);

if ~exist( highresVolDir, 'dir' ) % Handling expception due to inconsistent naming
    error( 'preprocessSetInput:NoMPRAGEDir', ...
        'MPRAGE dir %s for subject %s doesn''t exist.', ...
        highresVolDir, subjName );
end

listing = dir( highresVolDir );

if numel(listing) ~= 3
    error('preprocessSetInput:tooManyStructurals', ...
        'More or less than 1 file found in MPRAGE folder for subject %s.', ...
        subjName );
end

data.highresVol = {fullfile(listing(3).folder,  listing(3).name)};

% Setting all folders to move things to.
for i = 1:numel( subdirsOutput )
    subFldr = subdirsOutput{i};
    for j = 1:numel( subsubdirsOutput )
        subsubFldr = subsubdirsOutput{j};
        thisOutDir = fullfile( parentdirOutput, subFldr, subsubFldr );
        if ~exist( thisOutDir, 'dir' ); mkdir( thisOutDir ); end
        data.(subdirsOutputFldNames{i}){j} = thisOutDir;
    end
end

data.TopFldrRealignUnwrp = {fullfile( parentdirOutput, 'Realign_and_Unwarp' )};

end


% A script to convert each functional volume to csv for some statisitical
% learning project experiments
clear all

           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%   Things to change to be relevant to your system  %%%%%%%%%%%%
           %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Declaring file path parts to the data
subjImgs_topfolder = fullfile('C:','Users','Megan','Documents', ...
    'LevinStudy_Analysis_2018', 'Preprocessed_Data');
subjectsIDs = {'112', '116', '117', '119', '120', '131', '133', '135', ...
    '137', '148', '152', '153', '166', '178', '182', '184', '185', ...
    '186', '187', '190', '192', '193', '194', '196'}; % don't change
preprocFldr = 'smoothing'; % don't change
sessions = {'affect_1', 'affect_2', 'infant_1', 'infant_2'}; % don't change
motionFldr = 'Realign_and_Unwarp';
motionFilePart = 'rp_*.txt'; % grabbing the head motion estimate file too

% Where to write data
output_topfolder = fullfile('C:','Users','Megan','Documents',...
    'STAT432-StatisticalLearning-FinalProject','data','preprocessed_images');

                  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%      Don't touch the code below      %%%%%%%%%%%%%%%%%%
                  %   unless you know what you're doing  %
                  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get raw fMRI image for each subject and each session. 
% Makes rigid assumption about file hierarchy of data.
for thisSubject = subjectsIDs
    for thisSession = sessions
        % get file names for this session
        dataFilepath = fullfile(subjImgs_topfolder, thisSubject{:}, ...
            preprocFldr, thisSession{:});
        dataFiles = dir(dataFilepath);
        dataFiles = dataFiles( ~ismember( {dataFiles.name}, {'.','..'} ) );
        dataFiles = strcat({dataFiles.folder}, ...
            repmat({filesep}, size({dataFiles.name})), {dataFiles.name});
        
        % The data files should be in ascending temporal order. Using
        % knowledge of how the file names are constructed to do so. This
        % will only work if the data conforms to this standard (determined
        % by the scanner itself.
        expression = [regexptranslate('escape',filesep),'sw.*f.*-\d{4}-\d{5}-(\d{6})-\d{2}.*\.nii'];
        scanNumber = regexp(dataFiles, expression, 'tokens');
        dataFiles = dataFiles(find(~cellfun('isempty', scanNumber))); % getting rid of files that did not match the expected naming of valid scans
        scanNumber = cellfun(@(c) str2num(c{:}), [scanNumber{:}]); % acquisition order extracted from filename
        [~, order] = sort(scanNumber, 'ascend');
        dataFiles = dataFiles(order); % reodering data files to match acquisition order
        
        % read nifti file and write to csv
        % NTS: confirm that reslicing is being done on load. Not important
        % for the stats project this was written for, but good to know in
        % general.
        %
        % order of voxel determined by linear indexing conventions
        % and neurological (e.g. RAS) corrdinates for each image
        % each row is a image/volume, each column is a voxel.
        allNifti = cellfun(@(d) niftiread(d), dataFiles, ...
            'UniformOutput', false);
        allNifti = cellfun(@(d) reshape(d, [1, numel(d)]), allNifti, ...
            'UniformOutput', false);
        allNifti = cell2mat(allNifti');
         
        % Get ready to write data
        outputFilePath = fullfile(output_topfolder, ...
            thisSubject{:}, thisSession{:}); 
        if ~exist(outputFilePath, 'dir'); mkdir(outputFilePath); end
        
        % copy the motion parameter file
        motionFile = dir(fullfile(subjImgs_topfolder, thisSubject{:}, ...
            motionFldr, thisSession{:}, motionFilePart));
        copyfile(fullfile(motionFile.folder, motionFile.name), outputFilePath);
        
        % Write data
        dataFileName = fullfile(outputFilePath, ... 
            strcat(thisSubject{:}, '_', thisSession{:}, ... 
            '_allSmoothedImages.csv'));
        csvwrite(dataFileName, allNifti);
    end
end
% Batch script for extracting average voxel intensity from anatomical
% regions-of-interest (ROIs) as defined by the AAL atlas. Subjects assumed
% to be normalized into MNI space.
%
% Both SPM12 and the SPM12 toolbox Marsbar should be installed
% To use, start SPM12 in fMRI mode. Start the Marsbar toolbox within SPM12.
% Then run this script.
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

% Where the ROI definitions are. These were provided by Marsbar.
ROI_topfolder = fullfile('C:','Users','Megan','Documents',...
    'LevinStudy_Analysis_2018','scripts','extractROI-timecourses',...
    'marsbar-aal-0.2');

% Where to write data
output_topfolder = fullfile('C:','Users','Megan','Documents',...
    'STAT432-StatisticalLearning-FinalProject','data','ROI_timecourses');

                  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%      Don't touch the code below      %%%%%%%%%%%%%%%%%%
                  %   unless you know what you're doing  %
                  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ROIs_files = dir( fullfile(ROI_topfolder,'*.mat') ); % all .mat files should be ROI definitions
ROIs_files = ROIs_files( ~ismember( {ROIs_files.name}, {'.','..'} ) );
ROIs_files = strcat({ROIs_files.folder}, ...
    repmat({filesep}, size({ROIs_files.name})), {ROIs_files.name});

ROIs = maroi('load_cell', ROIs_files); % make maroi ROI objects

% Get time course for each subject and each session. 
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
        
        % Average of all points in the ROI calculated for each time point
        mY = get_marsy(ROIs{:}, cell2mat(dataFiles'), 'mean'); % extract data into marsy data object
        % Extract time course and estimated variance.
        % Variance is estimated population variance (i.e. divide by n-1)
        % -- variance calculated across all voxels within each ROI for each timepoint!
        % Data - rows = time points, cols = ROIs
        [y, y_var] = summary_data(mY); % get summary time course(s)
        
        % prep data for writing
        colNames = strsplit(summary_descrip(mY), ' & ');
        temp = strsplit(colNames{1}); colNames(1) = temp(3);
        varcolNames = cellfun(@(s) [s,'_variance'], colNames, ...
            'UniformOutput', false);
        
        % write data to file
        timecourses = array2table([y,y_var],...
            'VariableNames',[colNames, varcolNames]);
        
        outputFilePath = fullfile(output_topfolder, thisSubject{:}); 
        if ~exist(outputFilePath, 'dir'); mkdir(outputFilePath); end
        
        outputFileName = strcat(thisSubject{:}, '_', ...
            thisSession{:}, '_AALROImeanTimeCourses.csv');
        
        writetable(timecourses, fullfile(outputFilePath,outputFileName));
    end
end
% To-Do: Write script to check for prerequisite files and directory
% structure for entire pipeline. Cryptic errors happen when they are
% not in place.
clear
clc
load dcmConvert.mat

% subject should correspond with newIDs.
% 185 had a duplicate scan that may be removed from later analysis.
subjects = {'0003130', '0003080', '0003120', '0003081', '0003091', ...
    '0003128', '0003142', '0003146', '0003148', '148', '0003217', ...
    '0003227', '0003329', '178', '179', '182', '184', '185', '186', ...
    '187', '190', '192', '193', '194', '196', '185_2'}; % enter (dicom) subject IDs for 1st session
subjectsNewIDs = {'112', '116', '117', '119', '120', '131', '133', '135', ...
    '137', '148', '152', '153', '166', '178', '179', '182', '184', ...
    '185', '186', '187', '190', '192', '193', '194', '196', '185_2'}; % enter (nifti) subject IDs

numSubj = numel( subjects );

% Selecting all dicoms. Based on an assumption of how files are organized
SubjScanDirs = {};
for subjIndx = 1:numSubj
    SubjScanDirs = [ SubjScanDirs {getSubjDicomDirs( subjects{subjIndx} )}]; %#ok<AGROW>
end

maxNumDirs = max( cellfun( @(x)(size(x, 1)), SubjScanDirs  ) );

subject_batch = cell(numSubj, maxNumDirs);


for subjIndx = 1:numSubj
    
    thisSubjNIFTIname = subjectsNewIDs{subjIndx};
    thisSubjDirs = SubjScanDirs{subjIndx};    
    
    for dirIndx = 1:size(thisSubjDirs,1)
        
        thisDir = thisSubjDirs(dirIndx);
        
        if any(strfind(thisDir.name, 'PhoenixZIPReport')); continue; end % These are not image dicoms (SR dicoms)
        
        % update stuff in matlabbatch
        data = dcmConvertSetInput( thisSubjNIFTIname, thisDir);
        
        subject_batch{subjIndx, dirIndx} = matlabbatch;
        subject_batch{subjIndx, dirIndx}{1,1}.spm.util.import.dicom.data = data.dicoms;
        subject_batch{subjIndx, dirIndx}{1,1}.spm.util.import.dicom.outdir = data.niftiDir;
    end
end

data_out = cell(size(subject_batch));

for subjIndx = 1:size(subject_batch, 1)
    for dirIndx = 1:size(subject_batch, 2)
        if isempty(subject_batch(subjIndx, dirIndx)); continue; end
        try
            spm_jobman('initcfg') % I'm not 100% sure if needed, maybe it depends if a single machine or a cluster
            data_out{subjIndx, dirIndx} = spm_jobman('run',subject_batch{subjIndx, dirIndx});
        catch
            data_out{subjIndx, dirIndx} = 'error during batch setup - check the batch';
        end
    end
end


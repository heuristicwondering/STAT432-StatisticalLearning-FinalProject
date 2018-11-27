% Note: .ps files are not captured in the correct folders due to the
% parallel implementation of the code. Use the single subject version if
% you need them.
% Assumes dcmConvert has been run first.
clear
clc
load preprocess.mat

subjects = {'112', '116', '117', '119', '120', '131', '133', '135', ...
    '137', '148', '152', '153', '166', '178', '179', '182', '184', ...
    '185', '186', '187', '190', '192', '193', '194', '196'}; % enter (nifti) subject IDs

numSubj = numel( subjects );

subject_batch = cell(numSubj, 1);

for subjIndx = 1:numSubj   
    thisSubj = subjects{subjIndx};
    
    % update stuff in matlabbatch
    data = preprocessSetInput( thisSubj );
    
    subject_batch{subjIndx} = matlabbatch;
    % Slice Timing Correction
    subject_batch{subjIndx}{1,1}.spm.temporal.st.scans{1,1} = data.rawEPI{1,1};
    subject_batch{subjIndx}{1,1}.spm.temporal.st.scans{1,2} = data.rawEPI{1,2};
    subject_batch{subjIndx}{1,1}.spm.temporal.st.scans{1,3} = data.rawEPI{1,3};
    subject_batch{subjIndx}{1,1}.spm.temporal.st.scans{1,4} = data.rawEPI{1,4};
    % Coregistration
    subject_batch{subjIndx}{1,3}.spm.spatial.coreg.estimate.source = data.highresVol;
    % Moving Files
    subject_batch{subjIndx}{1,9}.cfg_basicio.file_dir.file_ops.file_move.action.moveto = data.SliceTimingFldr(1);
    subject_batch{subjIndx}{1,10}.cfg_basicio.file_dir.file_ops.file_move.action.moveto = data.SliceTimingFldr(2);
    subject_batch{subjIndx}{1,11}.cfg_basicio.file_dir.file_ops.file_move.action.moveto = data.SliceTimingFldr(3);
    subject_batch{subjIndx}{1,12}.cfg_basicio.file_dir.file_ops.file_move.action.moveto = data.SliceTimingFldr(4);
    subject_batch{subjIndx}{1,13}.cfg_basicio.file_dir.file_ops.file_move.action.moveto = data.RealignUnwrpFldr(1);
    subject_batch{subjIndx}{1,14}.cfg_basicio.file_dir.file_ops.file_move.action.moveto = data.RealignUnwrpFldr(2);
    subject_batch{subjIndx}{1,15}.cfg_basicio.file_dir.file_ops.file_move.action.moveto = data.RealignUnwrpFldr(3);
    subject_batch{subjIndx}{1,16}.cfg_basicio.file_dir.file_ops.file_move.action.moveto = data.RealignUnwrpFldr(4);
    subject_batch{subjIndx}{1,17}.cfg_basicio.file_dir.file_ops.file_move.action.moveto = data.TopFldrRealignUnwrp;
    subject_batch{subjIndx}{1,18}.cfg_basicio.file_dir.file_ops.file_move.action.moveto = data.NormlizeFldr(1);
    subject_batch{subjIndx}{1,19}.cfg_basicio.file_dir.file_ops.file_move.action.moveto = data.NormlizeFldr(2);
    subject_batch{subjIndx}{1,20}.cfg_basicio.file_dir.file_ops.file_move.action.moveto = data.NormlizeFldr(3);
    subject_batch{subjIndx}{1,21}.cfg_basicio.file_dir.file_ops.file_move.action.moveto = data.NormlizeFldr(4);
    subject_batch{subjIndx}{1,22}.cfg_basicio.file_dir.file_ops.file_move.action.moveto = data.SmoothingFldr(1);
    subject_batch{subjIndx}{1,23}.cfg_basicio.file_dir.file_ops.file_move.action.moveto = data.SmoothingFldr(2);
    subject_batch{subjIndx}{1,24}.cfg_basicio.file_dir.file_ops.file_move.action.moveto = data.SmoothingFldr(3);
    subject_batch{subjIndx}{1,25}.cfg_basicio.file_dir.file_ops.file_move.action.moveto = data.SmoothingFldr(4);

end

data_out = cell(size(subject_batch));

for subj = 1:length(subjects)
    if isempty( subject_batch(subj) ); continue; end
    try
        fprintf('Starting subject %s\n', subjects{subj});
        spm_jobman('initcfg') % I'm not 100% sure if needed, maybe it depends if if a single machine or a cluster
        data_out{subj} = spm_jobman('run',subject_batch{subj});
        fprintf('Completing subject %s\n', subjects{subj});
    catch
        data_out{subj} = 'error during batch setup - check the batch';
    end
end


% This scripts extracts scan lengths and associated subject IDs from the
% provided Excel file and saves them in a mat file for use in EV2CSV.

[CONN_ID,StudyID,Date,LCNIID,total_volumes,outvols,scan_lengths] = import_nii_notes('20170717_nii_notes.xlsx');

% Converting from cell string to numeric array
for i = 1:numel(scan_lengths)
    scan_lengths{i} = str2num(scan_lengths{i});
end
scan_lengths = cell2mat(scan_lengths);

% Converting a mixed type cell array to cell string array.
for i = 1:numel(StudyID)
    thisID = StudyID{i};
    
    if ischar( thisID ) % This data had both numbers and strings...
        subscrptIndx = strfind( thisID, '_' );
        if subscrptIndx % Dealing with the known exception in this file.
            StudyID{i} = thisID( 1 : (subscrptIndx - 1) );
        else
            StudyID{i} = StudyID{i};
        end  
    elseif isnumeric( thisID )
        StudyID{i} = num2str( StudyID{i} );
    else
        disp( 'The data in StudyID row %i was neither numeric or character!', i  );
    end
end

save('nii_notes', 'scan_lengths', 'StudyID');

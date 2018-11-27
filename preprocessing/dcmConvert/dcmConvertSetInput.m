function [ data ] = dcmConvertSetInput( thisSubjNIFTIname, thisDir )
%DCMCONVERTSETINPUT Initializes input variables
%   To keep code clean this sets all variables needed to populate the
%   associated batch loader dcmConvert.

% Parent folder from which all dicoms below will be selected
dicomTopFldr = fullfile( thisDir.folder, thisDir.name );

% Selecting dicoms. Assumes anything not a directory is a dicom file
listing = dir( fullfile( dicomTopFldr, '*' ) );
listing = listing( ~ismember( {listing.name}, {'.','..'} ) );

data.dicoms = cell( numel(listing), 1 );

for i = 1:numel(listing)
    data.dicoms{i} = fullfile( listing(i).folder, listing(i).name );
end

% Specifying directory to write NIFTI files to.
% Eliminating unnecessary file structure in this step.
dirParts = strsplit( thisDir.folder, filesep );
topFldrIndx = find( contains(dirParts, 'RawImaging_Data') );

if strcmp(thisDir.name, 'magnitude') || strcmp(thisDir.name, 'phase')
    thisDir.name = [ 'gre_fieldmap_', thisDir.name ]; % Just giving these clearer names
end

data.niftiDir = {fullfile( dirParts{1:topFldrIndx}, 'Raw_NIfTI', thisSubjNIFTIname, thisDir.name )};

if ~exist( data.niftiDir{:}, 'dir' )
    mkdir( data.niftiDir{:} );
end

end

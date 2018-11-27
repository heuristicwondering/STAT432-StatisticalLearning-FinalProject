function [ listing ] = getSubjDicomDirs( dicomName )
%GETSUBJDICOMDIRS Listing all the directories with dicom files to be
%converted for this subject.

% Parent directory of all subject dicoms.
parentDir = fullfile( 'C:', 'Users', 'Megan', 'Documents', 'LevinStudy_Analysis_2018', ...
    'RawImaging_Data', 'Sorted_Dicoms');

parentdir = strsplit( mfilename('fullpath'), filesep );
parentdir = fullfile( parentdir{1:end-4}, 'RawImaging_Data', 'Sorted_Dicoms' );

% fieldmaps contain two sets.
listing = dir( fullfile(parentDir, dicomName, '*') );

% If there is a fieldmap for this subject, then replace this listing with
% the listings for the two subfolders.
fieldIndx = contains( {listing.name}, 'field' );
if any( fieldIndx ) % NTS: Does this work for multiple folders?
    fieldMapPrntDir = listing(fieldIndx).folder;
    fieldMapDir = listing(fieldIndx).name;
    % NTS: I think this will fail for multiple folders. But not an issue in my dataset.
    fieldListing = dir( fullfile( fieldMapPrntDir, fieldMapDir, '*' ) );
    listing = [ listing(~fieldIndx); fieldListing ];
end

listing = listing( ~ismember( {listing.name}, {'.','..'} ) );

end


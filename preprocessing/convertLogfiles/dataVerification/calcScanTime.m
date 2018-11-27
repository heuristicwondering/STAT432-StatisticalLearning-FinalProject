function [ scanTime ] = calcScanTime( sessNum, subjName, Oregondicomreview )
%CALCSCANTIME Figuring out what the length of the scan 
% in seconds is for this session.

% Because there is wierdness in these subjects' naming.
weird = false;
if strcmp(subjName, '178')
    subjName = '178_2';
elseif strcmp(subjName, '182')
    subjName = 182;
    weird = true;
elseif strcmp(subjName, '192')
    subjName = 192;
    weird = true;
end

sessNum = str2num(sessNum);
if ~weird
    indx = find(strcmp( table2cell(Oregondicomreview(:,3)), subjName));
else
    indx = cellfun(@(x) x == subjName, table2cell(Oregondicomreview(:,3)), 'UniformOutput', false);
    indx = cellfun(@sum, indx);
    indx = find(indx);
end

% Grabbing all columns that have number of scans info for this subject
scans = table2cell( Oregondicomreview(indx, 11:24) );

% Collecting all the entries with numeric data.
scanIdx = 1;
for i = 1:numel(scans)
    thisScan = scans{i};
    if isnumeric(thisScan) && ~isnan(thisScan)
        scanVols(scanIdx) = thisScan;
        scanIdx = scanIdx + 1;
    end   
end

if scanIdx < 4
    fprintf('This is from debugging code that should be deleted.\n'); % debugging
end

% Making the rigid assumption that the 4 longest scans were the correct
% runs and that all others were aborted runs. This is based on visual
% inspection of the scans information.
[m, I] = sort(scanVols, 'descend');
try
    I = sort( I(1:4) );
catch
    error('calcScanTime:notEnoughData', 'Are there at least 4 scan length entries?');
end
scanVols = scanVols(I);

% Also assuming scans were collected in the session order: 1_own/other (1),
% 2_own/other (2), 1_look/label (3), 2_look/label (4) so that the session
% number specified in the ev file can be used to index the correct scan
% length. This is based on communication with Heidemarie.
TR = 2; % Assuming same TR for all scans
scanLength = scanVols(sessNum);
scanTime = scanLength * 2;

end


function [Rng,FreqList] = dbrange(D,List,varargin)
% dbrange  Find a range that encompasses the ranges of the listed tseries objects.
%
% Syntax
% =======
%
%     [Range,FreqList] = dbrange(D)
%     [Range,FreqList] = dbrange(D,List,...)
%     [Range,FreqList] = dbrange(D,Inf,...)
%
% Input arguments
% ================
%
% * `D` [ struct ] - Input database.
%
% * `List` [ char | cellstr | `Inf` ] - List of tseries objects that will
% be included in the range search; `Inf` means all tseries objects existing in
% the input databases will be included.
%
% Output arguments
% =================
%
% * `Range` [ numeric | cell ] - Range that encompasses the observations of
% the tseries objects in the input database; if tseries objects with
% different frequencies exist, the ranges are returned in a cell array.
%
% * `FreqList` [ numeric ] - Vector of date frequencies coresponding to the
% returned ranges.
%
% Options
% ========
%
% * `'startDate='` [ *`'maxRange'`* | `'minRange'` ] - `'maxRange'` means
% the `range` will start at the earliest start date of all tseries included
% in the search; `'minRange'` means the `range` will start at the latest
% start date found.
%
% * `'endDate='` [ *`'maxRange'`* | `'minRange'` ] - `'maxRange'` means the
% `range` will end at the latest end date of all tseries included in the
% search; `'minRange'` means the `range` will end at the earliest end date.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

try
    if ischar(List)
        List = regexp(List,'\w+','match');
    end
catch %#ok<CTCH>
    List = Inf;
end

% Validate input arguments.
pp = inputParser();
pp.addRequired('D',@isstruct);
pp.addRequired('List',@(x) iscellstr(x) || isequal(x,Inf));
pp.parse(D,List);


% Validate options.
opt = passvalopt('dbase.dbrange',varargin{:});

%--------------------------------------------------------------------------

if isequal(List,Inf)
    List = fieldnames(D);
end

FreqList = [0,1,2,4,6,12,52];
nFreq = length(FreqList);
startDat = cell(1,nFreq);
endDat = cell(1,nFreq);
Rng = cell(1,nFreq);
nList = numel(List);

for i = 1 : nList
    if isfield(D,List{i}) && is.tseries(D.(List{i}))
        x = D.(List{i});
        freqInx = freq(x) == FreqList;
        if any(freqInx)
            startDat{freqInx}(end+1) = startdate(x);
            endDat{freqInx}(end+1) = enddate(x);
        end
    end
end

if any(strcmpi(opt.startdate,{'maxrange','unbalanced'}))
    startDat = cellfun(@min,startDat,'uniformOutput',false);
else
    startDat = cellfun(@max,startDat,'uniformOutput',false);
end

if any(strcmpi(opt.enddate,{'maxrange','unbalanced'}))
    endDat = cellfun(@max,endDat,'uniformOutput',false);
else
    endDat = cellfun(@min,endDat,'uniformOutput',false);
end

for i = find(~cellfun(@isempty,startDat))
    Rng{i} = startDat{i} : endDat{i};
end

isEmpty = cellfun(@isempty,Rng);
if sum(~isEmpty) == 0
    Rng = [];
    FreqList = [];
elseif sum(~isEmpty) == 1
    Rng = Rng{~isEmpty};
    FreqList = FreqList(~isEmpty);
else
    Rng = Rng(~isEmpty);
    FreqList = FreqList(~isEmpty);
end

end
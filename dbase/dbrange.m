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
% -Copyright (c) 2007-2013 IRIS Solutions Team.

try
    if ischar(List)
        List = regexp(List,'\w+','match');
    end
catch %#ok<CTCH>
    List = Inf;
end

% Validate input arguments.
pp = inputParser();
pp = pp.addRequired('D',@isstruct);
pp = pp.addRequired('List',@(x) iscellstr(x) || isequal(x,Inf));
pp = pp.parse(D,List);

% Validate options.
opt = passvalopt('dbase.dbrange',varargin{:});

%--------------------------------------------------------------------------

if isequal(List,Inf)
    List = fieldnames(D);
end

FreqList = [1,2,4,6,12,0];
startDat = cell(1,6);
endDat = cell(1,6);
Rng = cell(1,6);
nList = numel(List);

for i = 1 : nList
    if isfield(D,List{i}) && istseries(D.(List{i}))
        x = D.(List{i});
        freqindex = freq(x) == FreqList;
        if any(freqindex)
            startDat{freqindex}(end+1) = startdate(x);
            endDat{freqindex}(end+1) = enddate(x);
        end
    end
end

if isanychari(opt.startdate,{'maxrange','unbalanced'})
    startDat = cellfun(@min,startDat,'uniformOutput',false);
else
    startDat = cellfun(@max,startDat,'uniformOutput',false);
end

if isanychari(opt.enddate,{'maxrange','unbalanced'})
    endDat = cellfun(@max,endDat,'uniformOutput',false);
else
    endDat = cellfun(@min,endDat,'uniformOutput',false);
end

for i = find(~cellfun(@isempty,startDat))
    Rng{i} = startDat{i} : endDat{i};
end

nonEmpty = ~cellfun(@isempty,Rng);
if sum(nonEmpty) == 0
    Rng = [];
    FreqList = [];
elseif sum(nonEmpty) == 1
    Rng = Rng{nonEmpty};
    FreqList = FreqList(nonEmpty);
else
    Rng = Rng(nonEmpty);
    FreqList = FreqList(nonEmpty);
end

end
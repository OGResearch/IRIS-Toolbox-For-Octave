function [X,Incl,Range,NotFound,NonTseries] = ...
    db2array(D,List,Range,LagOrLead,Log,Warn)
% db2array  Convert tseries database entries to numeric array.
%
% Syntax
% =======
%
%     [X,Incl,Range] = db2array(D)
%     [X,Incl,Range] = db2array(D,List)
%     [X,Incl,Range] = db2array(D,List,Range)
%
% Input arguments
% ================
%
% * `D` [ struct ] - Input database with tseries objects that will be
% converted to a numeric array.
%
% * `List` [ char | cellstr ] - List of tseries names that will be
% converted to a numeric array; if not specified, all tseries
% entries found in the input database, `D`, will be included in the output
% arrays, `X`.
%
% * `Range` [ numeric | `Inf` ] - Date range; `Inf` means a range from the
% very first non-NaN observation to the very last non-NaN observation.
%
% Output arguments
% =================
%
% * `X` [ numeric ] - Numeric array with observations from individual
% tseries objects in columns.
%
% * `Incl` [ cellstr ] - List of tseries names that have been actually
% found in the database.
%
% * `Range` [ numeric ] - Date range actually used; this output argument is
% useful when the input argument `Range` is missing or `Inf`.
%
% Description
% ============
%
% The output array, `X`, is always NPer-by-NList-by-NAlt, where NPer is the
% length of the `Range` (the number of periods), NList is the number of
% tseries included in the `List`, and NAlt is the maximum number of columns
% that any of the tseries included in the `List` have.
%
% All tseries with more than one dimension (i.e. with more than one column)
% are always expanded along 3rd dimension only. For instance, a
% 10-by-2-by-3 tseries will occupy a 10-by-1-by-6 space in `X` at its
% respective location.
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%#ok<*VUNUS>
%#ok<*CTCH>

try
    List;
catch
    List = dbnames(D,'classFilter=','tseries');
end

try
    Range;
catch
    Range = Inf;
end

try
    LagOrLead;
catch
    LagOrLead = [];
end

try
    Log;
catch
    Log = [];
end

try
    Warn;
catch
    Warn = struct();
end

try
    Warn.notFound;
catch
    Warn.notFound = true;
end

try
    Warn.sizeMismatch;
catch
    Warn.sizeMismatch = true;
end

try
    Warn.freqMismatch;
catch
    Warn.freqMismatch = true;
end

try
    Warn.nonTseries;
catch
    Warn.nonTseries = true;
end

% Swap `List` and `Range` if needed.
if isnumeric(List) && (iscellstr(Range) || ischar(Range))
    [List,Range] = deal(Range,List);
end

%--------------------------------------------------------------------------

if ischar(List)
    List = regexp(List,'\w+','match');
end
List = List(:).';

range2 = [];
if any(isinf(Range([1,end])))
    range2 = dbrange(D,List);
    if isempty(range2)
        utils.warning('dbase', ...
            ['No tseries entries found in the list ', ...
            'of entries included in the output array.']);
        return
    end
end

if isinf(Range(1))
    startDate = range2(1);
else
    startDate = Range(1);
end

if isinf(Range(end))
    endDate = range2(end);
else
    endDate = Range(end);
end

Range = startDate : endDate;
rangeFreq = datfreq(startDate);
nPer = numel(Range);

X = nan(nPer,0);
nList = length(List);
NotFound = false(1,nList);
Invalid = false(1,nList);
Incl = false(1,nList);
freqMismatch = false(1,nList);
NonTseries = false(1,nList);

for i = 1 : nList
    name = List{i};
    if ~isfield(D,name)
        NotFound(i) = true;
        continue
    end
    if is.tseries(D.(name))
        Xi = [];
        doGetTseriesData();
        doAddData();
    else
        NonTseries(i) = true;
    end
end

Incl = List(Incl);

doWarning();

if isempty(X)
    X = nan(nPer,nList);
end

% Nested functions.

%**************************************************************************
    function doGetTseriesData()
        tmpFreq = freq(D.(name));
        if ~isnan(tmpFreq) && rangeFreq ~= tmpFreq
            nData = max(1,size(X,3));
            Xi = nan(nPer,nData);
            freqMismatch(i) = true;
        else
            k = 0;
            if ~isempty(LagOrLead)
                k = LagOrLead(i);
            end
            Xi = rangedata(D.(name),Range+k);
            % Make sure the input data are 2D only.
            Xi = Xi(:,:);
        end
    end % doGetTseriesData().

%**************************************************************************
    function doAddData()
        if isempty(X)
            X = nan(nPer,nList,size(Xi,2));
        end
        nAltX = size(X,3);
        nAltXi = size(Xi,2);
        % If needed, expand number of alternatives in current array or current
        % addition.
        if nAltX == 1 && nAltXi > 1
            X = X(:,:,ones(1,nAltXi));
            nAltX = nAltXi;
        elseif nAltX > 1 && nAltXi == 1
            Xi = Xi(:,ones(1,nAltX));
            nAltXi = nAltX;
        end
        if nAltX == nAltXi
            if ~isempty(Log) && Log(i)
                Xi = log(Xi);
            end
            X(:,i,1:nAltXi) = permute(Xi,[1,3,2]);
            Incl(i) = true;
        else
            Invalid(i) = true;
        end
    end % doAddData().

%**************************************************************************
    function doWarning()
        if Warn.notFound && any(NotFound)
            utils.warning('dbase', ...
                ['This name does not exist ', ...
                'in the database: ''%s''.'], ...
                List{NotFound});
        end
        
        if Warn.sizeMismatch && any(Invalid)
            utils.warning('dbase', ...
                ['This database entry does not match ', ...
                'the size of others: ''%s''.'], ...
                List{Invalid});
        end
        
        if Warn.freqMismatch && any(freqMismatch)
            utils.warning('dbase', ...
                ['This database entry does not match ', ...
                'the frequency of the dates requested: ''%s''.'], ...
                List{freqMismatch});
        end
        
        if Warn.nonTseries && any(NonTseries)
            utils.warning('dbase', ...
                ['This name exists in the database, ', ...
                'but is not a tseries object: ''%s''.'], ...
                List{NonTseries});
        end
    end % doWarning().

end

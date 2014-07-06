function [X,ixIncl,Range,IxNotFound,IxNonTseries] ...
    = db2array(D,List,Range,Sw)
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
    Sw;
catch
    Sw = struct();
end

try
    Sw.LagOrLead;
catch
    Sw.LagOrLead = [];
end

try
    Sw.Log;
catch
    Sw.Log = [];
end

try
    Sw.Warn;
catch
    Sw.Warn = struct();
end

try
    Sw.Warn.NotFound;
catch
    Sw.Warn.NotFound = true;
end

try
    Sw.Warn.SizeMismatch;
catch
    Sw.Warn.SizeMismatch = true;
end

try
    Sw.Warn.FreqMismatch;
catch
    Sw.Warn.FreqMismatch = true;
end

try
    Sw.Warn.NonTseries;
catch
    Sw.Warn.NonTseries = true;
end

try
    Sw.Warn.NoRangeFound;
catch
    Sw.Warn.NoRangeFound = true;
end

try
    Sw.BaseYear;
catch
    Sw.BaseYear = @config;
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

nList = length(List);
ixInvalid = false(1,nList);
ixIncl = false(1,nList);
ixFreqMismatch = false(1,nList);
IxNotFound = false(1,nList);
IxNonTseries = false(1,nList);

range2 = [];
if any(isinf(Range([1,end])))
    range2 = dbrange(D,List);
    if isempty(range2)
        if Sw.Warn.NoRangeFound
            utils.warning('dbase', ...
                ['Cannot determine range because ', ...
                'no tseries entries have been found in the database.']);
        end
        X = [];
        Range = [];
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
for i = 1 : nList
    name = List{i};
    try
        nData = max(1,size(X,3));
        if strcmp(name,'!ttrend')
            Xi = [];
            doGetTtrend();
            doAddData();
        else
            field = D.(name);
            if is.tseries(field)
                Xi = [];
                doGetTseriesData();
                doAddData();
            else
                IxNonTseries(i) = true;
            end
        end
    catch
        IxNotFound(i) = true;
        continue
    end
end

ixIncl = List(ixIncl);

doWarning();

if isempty(X)
    X = nan(nPer,nList);
end


% Nested functions...


%**************************************************************************


    function doGetTseriesData()
        tmpFreq = freq(field);
        if ~isnan(tmpFreq) && rangeFreq ~= tmpFreq
            nData = max(1,size(X,3));
            Xi = nan(nPer,nData);
            ixFreqMismatch(i) = true;
        else
            k = 0;
            if ~isempty(Sw.LagOrLead)
                k = Sw.LagOrLead(i);
            end
            Xi = rangedata(field,Range+k);
            % Make sure the input data are 2D only.
            Xi = Xi(:,:);
        end
    end % doGetTseriesData()


%**************************************************************************


    function doGetTtrend()
        k = 0;
        if ~isempty(Sw.LagOrLead)
            k = Sw.LagOrLead(i);
        end
        Xi = dat2ttrend(Range+k,Sw.BaseYear);
        Xi = Xi(:);
    end % doGetTtrend()


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
            if ~isempty(Sw.Log) && Sw.Log(i)
                Xi = log(Xi);
            end
            X(:,i,1:nAltXi) = permute(Xi,[1,3,2]);
            ixIncl(i) = true;
        else
            ixInvalid(i) = true;
        end
    end % doAddData()


%**************************************************************************


    function doWarning()
        if Sw.Warn.NotFound && any(IxNotFound)
            utils.warning('dbase', ...
                ['This name does not exist ', ...
                'in the database: ''%s''.'], ...
                List{IxNotFound});
        end
        
        if Sw.Warn.SizeMismatch && any(ixInvalid)
            utils.warning('dbase', ...
                ['This database entry does not match ', ...
                'the size of others: ''%s''.'], ...
                List{ixInvalid});
        end
        
        if Sw.Warn.FreqMismatch && any(ixFreqMismatch)
            utils.warning('dbase', ...
                ['This database entry does not match ', ...
                'the frequency of the dates requested: ''%s''.'], ...
                List{ixFreqMismatch});
        end
        
        if Sw.Warn.NonTseries && any(IxNonTseries)
            utils.warning('dbase', ...
                ['This name exists in the database, ', ...
                'but is not a tseries object: ''%s''.'], ...
                List{IxNonTseries});
        end
    end % doWarning()


end

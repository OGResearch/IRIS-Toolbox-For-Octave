function This = subsasgn(This,S,Y)
% subsasgn  Subscripted assignment for tseries objects.
%
% Syntax
% =======
%
%     x(dates) = values;
%     x(dates,i,j,k,...) = values;
%
% Input arguments
% ================
%
% * `x` [ tseries ] - Tseries object that will be assigned new
% observations.
%
% * `dates` [ numeric ] - Dates for which the new observations will be
% assigned.
%
% * `i`, `j`, `k`, ... [ numeric ] - References to 2nd and higher
% dimensions of the tseries object.
%
% * `values` [ numeric ] - New observations that will assigned at specified
% dates.
%
% Output arguments
% =================
%
% * `x` [ tseries ] - Tseries object with newly assigned observations.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isnumeric(S)
    % Simplified syntax: subsasgn(x,dates,y)
    dates = S;
    S = struct();
    S.type = '()';
    S.subs{1} = dates;
end

switch S(1).type
    case {'()' '{}'}
        % Run `mylagorlead` to tell if the first reference is a lag/lead. If yes,
        % the startdate of `x` will be adjusted within `mylagorlead`.
        [This,S,shift] = mylagorlead(This,S);
        if isempty(S)
            return
        end
        % After a lag or lead, only one ()-reference is allowed.
        if length(S) > 1 || ~isequal(S(1).type,'()')
            utils.error('tseries', ...
                ['Invalid subscripted reference or assignment ', ...
                'to tseries object.']);
        end
        This = xxSetData(This,S,Y);
        % Shift start date back.
        if shift ~= 0
            This.start = This.start + shift;
        end
    otherwise
        % Give standard access to public properties.
        This = builtin('subsasgn',This,S,Y);
end

end

% Subfunctions.

%**************************************************************************
function X = xxSetData(X,S,Y)

% Pad LHS tseries data with NaNs to comply with references.
% Remove the rows from dates that do not pass the frequency test.
[X,S,dates,freqTest] = xxExpand(X,S);

% Get RHS tseries object data.
if istseries(Y)
    Y = mygetdata(Y,dates);
end

% Convert LHS tseries NaNs to complex if LHS is real and RHS is complex.
if isreal(X.data) && ~isreal(Y)
    X.data(isnan(X.data)) = NaN + 1i*NaN;
end

% If RHS has only one row but multiple cols (or size > 1 in other dims),
% tseries is multivariate, and assigned are multiple dates, then expand RHS
% in 1st dimension.
xSize = size(X.data);
ySize = size(Y);
if length(Y) > 1 && size(Y,1) == 1 ...
        && length(S.subs{1}) > 1 ...
        && any(xSize(2:end) > 1)
    n = length(S.subs{1});
    Y = reshape(Y(ones(1,n),:),[n,ySize(2:end)]);
end

% Report frequency mismatch.
% Remove the rows from RHS that do not pass the frequency test.
ySize = size(Y);
if any(~freqTest)
    utils.warning('tseries', ...
        'Date frequency mismatch in assignment to tseries object.');
    if ySize(1) == length(freqTest)
        Y = Y(freqTest,:);
        Y = reshape(Y,[size(Y,1),ySize(2:end)]);
    end
end

X.data = subsasgn(X.data,S,Y);
% Make sure empty tseries have start date set to NaN no matter what.
if isempty(X.data)
    X.start = NaN;
end

% If RHS is empty and first index is ';', then some of the columns have
% been deleted, and the comments must be adjusted accordingly.
if isempty(Y) && strcmp(S.subs{1},':')
    X.Comment = subsasgn(X.Comment,S,Y);
end

X = mytrim(X);

end % xxSetData().

%**************************************************************************
function [X,S,Dates,FreqTest] = xxExpand(X,S)

% If LHS data are complex, use NaN+NaNi to pad missing observations.
if isreal(X.data)
    unit = 1;
else
    unit = 1 + 1i;
end

% Replace x(dates) with x(dates,:,...,:).
if length(S.subs) == 1
    S.subs(2:ndims(X.data)) = {':'};
end

% Inf and ':' produce the entire tseries range.
% Convert subscripts in 1st dimension from dates to indices.
if isequal(S.subs{1},':') || isequal(S.subs{1},Inf)
    S.subs{1} = ':';
    if isnan(X.start)
        % LHS is empty.
        Dates = [];
    else
        Dates = X.start + (0 : size(X.data,1)-1);
    end
    FreqTest = true(size(Dates));
elseif isnumeric(S.subs{1}) && ~isempty(S.subs{1})
    Dates = S.subs{1};
    if ~isempty(Dates)
        f2 = Dates - floor(Dates);
        if isnan(X.start)
            % If LHS series is empty tseries, set start date to the minimum
            % date with the same frequency as the first date.
            X.start = min(Dates(f2 == f2(1)));
        end
        f1 = X.start - floor(X.start);
        FreqTest = abs(f1 - f2) < 1e-2;
        Dates(~FreqTest) = [];
        S.subs{1} = round(Dates - X.start + 1);
    end
else
    Dates = [];
    FreqTest = [];
end

% Reshape tseries data to reduce number of dimensions if called with
% fewer dimensions. Eg x.data is Nx2x2, and assignment is for x(:,3).
% This mimicks standard Matlab behaviour.
nSubs = length(S.subs);
reshaped = false;
if nSubs < ndims(X.data)
    tempSubs = cell([1,nSubs]);
    tempSubs(:) = {':'};
    tempSize = size(X.data);
    X.data = X.data(tempSubs{:});
    X.Comment = X.Comment(tempSubs{:});
    reshaped = true;
end

% Add NaNs to data when user indices go beyond the data size.
% Add NaNs to 1st dimension when user indices are non-positive.
% Add empty strings for comments to comply with new size.
% This modifies standard Matlab matrix assignment, which produces zeros.
for i = find(~strcmp(':',S.subs))
    % Non-positive index in 1st dimension.
    if i == 1 && any(S.subs{1} < 1)
        n = 1 - min(S.subs{1});
        currentSize = size(X.data);
        currentSize(1) = n;
        X.data = [nan(currentSize)*unit;X.data];
        X.start = X.start - n;
        S.subs{1} = S.subs{1} + n;
    end
    % If index exceeds current size, add NaNs. This is different than
    % standard Matlab behaviour: Matlab adds zeros.
    if any(S.subs{i} > size(X.data,i))
        currentSize = size(X.data);
        currentSize(end+1:nSubs) = 1;
        addSize = currentSize;
        addSize(i) = max(S.subs{i}) - addSize(i);
        X.data = cat(i,X.data,nan(addSize)*unit);
        if i > 1
            % Add an appropriate empty cellstr to comments if tseries data
            % are expanded in 2nd or higher dimensions.
            comment = cell([1,addSize(2:end)]);
            comment(:) = {''};
            X.Comment = cat(i,X.Comment,comment);
        end
    end
end

% Try to reshape tseries data array back.
if reshaped
    try
        X.data = reshape(X.data,tempSize);
        X.Comment = reshape(X.Comment,[1,tempSize(2:end)]);
    catch %#ok<CTCH>
        error('iris:tseries', ...
            'Attempt to grow tseries data array along ambiguous dimension.');
    end
end

end % xxExpand().
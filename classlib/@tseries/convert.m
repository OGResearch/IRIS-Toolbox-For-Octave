function This = convert(This,Freq2,Range,varargin)
% convert  Convert tseries object to a different frequency.
%
% Syntax
% =======
%
%     Y = convert(X,NewFreq)
%     Y = convert(X,NewFreq,Range,...)
%
% Input arguments
% ================
%
% * `X` [ tseries ] - Input tseries object that will be converted to a new
% frequency, `freq`, aggregating or intrapolating the data.
%
% * `NewFreq` [ numeric | char ] - New frequency to which the input data
% will be converted: `1` or `'A'` for annual, `2` or `'H'` for half-yearly,
% `4` or `'Q'` for quarterly, `6` or `'B'` for bi-monthly, and `12` or
% `'M'` for monthly.
%
% * `Range` [ numeric ] - Date range on which the input data will be
% converted.
%
% Output arguments
% =================
%
% * `Y` [ tseries ] - Output tseries created by converting `X` to the new
% frequency.
%
% Options
% ========
%
% * `'ignoreNaN='` [ `true` | *`false`* ] - Exclude NaNs from agreggation.
%
% * `'missing='` [ numeric | *`NaN`* | `'last'` ] - Replace missing
% observations with this value.
%
% Options for high- to low-frequency conversion (aggregation)
% ============================================================
%
% * `'method='` [ function_handle | `'first'` | `'last'` | *`@mean`* ] -
% Method that will be used to aggregate the high frequency data.
%
% * `'select='` [ numeric | *`Inf`* ] - Select only these high-frequency
% observations within each low-frequency period; Inf means all observations
% will be used.
%
% Options for low- to high-frequency conversion (interpolation)
% ==============================================================
%
% * `'method='` [ char | *`'cubic'`* | `'quadsum'` | `'quadavg'` ] -
% Interpolation method; any option available in the built-in `interp1`
% function can be used.
%
% * `'position='` [ *`'centre'`* | `'start'` | `'end'` ] - Position of the
% low-frequency date grid.
%
% Description
% ============
%
% The function handle that you pass in through the 'method' option when you
% aggregate the data (convert higher frequency to lower frequency) should
% behave like the built-in functions `mean`, `sum` etc. In other words, it
% is expected to accept two input arguments:
%
% * the data to be aggregated,
% * the dimension along which the aggregation is calculated.
%
% The function will be called with the second input argument set to 1, as
% the data are processed en block columnwise. If this call fails, `convert`
% will attempt to call the function with just one input argument, the data,
% but this is not a safe option under some circumstances since dimension
% mismatch may occur.
%
% Example
% ========

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

if isempty(This)
    utils.warning('tseries', ...
        'Tseries object is empty, no conversion made.');
    return
end

freq1 = datfreq(This.start);
Freq2 = xxRecogniseFreq(Freq2);

if isempty(Freq2)
    utils.error('tseries', ...
        'Cannot determine requested output frequency.');
end

if nargin < 3
    Range = Inf;
end

if freq1 == Freq2
    % No conversion.
    if isequal(Range,Inf)
        return
    else
        This.data = rangedata(This,Range);
        This.start = Range(1);
        This = mytrim(This);
        return
    end
elseif freq1 == 0
    % Conversion of daily series.
    opt = passvalopt('tseries.convertdaily',varargin{:});
    call = @xxDailyAggregate;
else
    % Conversion of Y, Z, Q, B, or M series.
    if freq1 > Freq2
        % Aggregate.
        opt = passvalopt('tseries.convertaggregate',varargin{:});
        if ~isempty(opt.function)
            opt.method = opt.function;
        end
        call = @xxAggregate;
    else
        % Interpolate.
        opt = passvalopt('tseries.convertinterp',varargin{:});
        if any(strcmpi(opt.method,{'quadsum','quadavg'}))
            % Quadratic interpolation matching sum or average.
            call = @xxInterpMatch;
        else
            % Built-in interp1.
            call = @xxInterp;
        end
    end
end

%--------------------------------------------------------------------------

This = call(This,Range,freq1,Freq2,opt);

end

% Subfunctions.

%**************************************************************************
function freq = xxRecogniseFreq(freq)

freqNum = [1,2,4,6,12];
if ischar(freq)
    if ~isempty(freq)
        freqLetter = 'yzqbm';
        freq = lower(freq(1));
        if freq == 'a'
            % Dual options for annual frequency: Y or A.
            freq = 'y';
        elseif freq == 's'
            % Dual options for semi-annual frequency: Z or S.
            freq = 'z';
        end
        freq = freqNum(freq == freqLetter);
    else
        freq = [];
    end
elseif ~any(freq == freqNum)
    freq = [];
end

end % xxRecogniseFreq().

%**************************************************************************
function x = xxAggregate(x,range,fromfreq,tofreq,options)
if isa(options.method,'function_handle') ...
        && any(strcmp(char(options.method),{'first','last'}))
    options.method = char(options.method);
end

if ischar(options.method)
    options.method = str2func(options.method);
end

if isnan(x.start) && isempty(x.data)
    return
end

if isempty(range)
    x = empty(x);
    return
end

if ~any(isinf(range))
    x = resize(x,range);
end

datfunc = {@yy,@zz,@qq,@bb,@mm};
fromdate = datfunc{fromfreq == [1,2,4,6,12]};
todate = datfunc{tofreq == [1,2,4,6,12]};

startyear = dat2ypf(get(x,'start'));
endyear = dat2ypf(get(x,'end'));

fromdata = mygetdata(x,fromdate(startyear,1):fromdate(endyear,fromfreq));
fromdatasize = size(fromdata);
nper = fromdatasize(1);
fromdata = fromdata(:,:);
nfromdata = size(fromdata,2);
factor = fromfreq/tofreq;
todata = nan(nper/factor,nfromdata);
for i = 1 : size(fromdata,2)
    tmpdata = reshape(fromdata(:,i),[factor,nper/factor]);
    if ~isequal(options.select,Inf)
        tmpdata = tmpdata(options.select,:);
    end
    if options.ignorenan && any(isnan(fromdata(:,i)))
        for j = 1 : size(tmpdata,2)
            index = ~isnan(tmpdata(:,j));
            if any(index)
                try
                    todata(j,i) = options.method(tmpdata(index,j),1);
                catch %#ok<CTCH>
                    todata(j,i) = NaN;
                end
            else
                todata(j,i) = NaN;
            end
        end
    else
        try
            todata(:,i) = options.method(tmpdata,1);
        catch %#ok<CTCH>
            try %#ok<TRYNC>
                todata(:,i) = options.method(tmpdata);
            end
        end
    end
end
todata = reshape(todata,[nper/factor,fromdatasize(2:end)]);

x.start = todate(startyear,1);
x.data = todata;
x = mytrim(x);

end % xxAggregate().

%**************************************************************************
function x = first(x,varargin) %#ok<DEFNU>
x = x(1,:);
end % first().

%**************************************************************************
function x = last(x,varargin) %#ok<DEFNU>
x = x(end,:);
end % last().

%**************************************************************************
function This = ...
    xxDailyAggregate(This,UserRange,Freq1,Freq2,Opt) %#ok<INUSL>

if ischar(Opt.method)
    Opt.method = str2func(Opt.method);
end

if any(isinf(UserRange))
    UserRange = This.start + (0 : size(This.data,1)-1);
else
    UserRange = UserRange(1) : UserRange(end);
end

periodFunc = @(month) ceil(Freq2*month/12);
dateFunc = @(year,period) datcode(Freq2,year,period);

start = This.start;
data = This.data;

range = start + (0 : size(data,1)-1);
if isempty(range)
    return
end

tmpsize = size(data);
data = data(:,:);

tmp = datevec(UserRange);
useryear = tmp(:,1);
userperiod = periodFunc(tmp(:,2));

tmp = datevec(range);
year = tmp(:,1);
period = periodFunc(tmp(:,2));

% Treat missing observations.
for t = 2 : size(data,1)
    inx = isnan(data(t,:));
    if any(inx)
        switch Opt.missing
            case 'last'
                data(t,inx) = data(t-1,inx);
            otherwise
                data(t,inx) = Opt.missing;
        end
    end
end

start2 = dateFunc(useryear(1),userperiod(1));
data2 = [];
while ~isempty(useryear)
    inx = year == useryear(1) & period == userperiod(1);
    x = data(inx,:);
    nx = size(x,2);
    xAgg = nan(1,nx);
    for i = 1 : nx
        tmp = x(:,i);
        if Opt.ignorenan
            tmp = tmp(~isnan(tmp));
        end
        if isempty(tmp)
            xAgg(1,i) = NaN;
        else
            try
                xAgg(1,i) = Opt.method(tmp,1);
            catch %#ok<CTCH>
                try %#ok<TRYNC>
                    xAgg(1,i) = Opt.method(tmp);
                end
            end
        end
    end
    data2 = [data2;xAgg]; %#ok<AGROW>
    year(inx) = [];
    period(inx) = [];
    data(inx,:) = [];
    inx = useryear == useryear(1) & userperiod == userperiod(1);
    useryear(inx) = [];
    userperiod(inx) = [];
end

data2 = reshape(data2,[size(data2,1),tmpsize(2:end)]);

This.start = start2;
This.data = data2;
This = mytrim(This);

end % xxdailyaggregate().

%**************************************************************************
function This = xxInterp(This,Range1,Freq1,Freq2,Opt)

if isnan(This.start) && isempty(This.data)
    return
end
if isempty(Range1)
    This = empty(This);
    return
end
if ~any(isinf(Range1))
    Range1 = Range1(1) : Range1(end);
end

[xData,Range1] = mygetdata(This,Range1);
xSize = size(xData);
xData = xData(:,:);

[startYear1,startPer1] = dat2ypf(Range1(1));
[endYear1,endPer1] = dat2ypf(Range1(end));

startYear2 = startYear1;
endYear2 = endYear1;
% Find the earliest freq2 period contained (at least partially) in freq1
% start period.
startPer2 = 1 + floor((startPer1-1)*Freq2/Freq1);
% Find the latest freq2 period contained (at least partially) in freq1 end
% period.
endper2 = ceil((endPer1)*Freq2/Freq1);
range2 = ...
    datcode(Freq2,startYear2,startPer2) : datcode(Freq2,endYear2,endper2);

grid1 = dat2grid(Range1,Opt.position);
grid2 = dat2grid(range2,Opt.position);
xData2 = interp1(grid1,xData,grid2,Opt.method,'extrap');
if size(xData2,1) == 1 && size(xData2,2) == length(range2)
    xData2 = xData2(:);
else
    xData2 = reshape(xData2,[size(xData2,1),xSize(2:end)]);
end
This.start = range2(1);
This.data = xData2;
This = mytrim(This);

end % xxInterp().

%**************************************************************************
function This = xxInterpMatch(This,Range1,Freq1,Freq2,Opt)

if isnan(This.start) && isempty(This.data)
    return
end
if isempty(Range1)
    This = empty(This);
    return
end
if ~any(isinf(Range1))
    Range1 = Range1(1) : Range1(end);
end

n = Freq2/Freq1;
if n ~= round(n)
    error('iris:tseris',...
        'Source and target frequencies incompatible for ''%s'' interpolation.',...
        Opt.method);
end

[xData,Range1] = mygetdata(This,Range1);
xSize = size(xData);
xData = xData(:,:);

[startYear1,startPer1] = dat2ypf(Range1(1));
[endYear1,endPer1] = dat2ypf(Range1(end));

startYear2 = startYear1;
endYear2 = endYear1;
% Find the earliest freq2 period contained (at least partially) in freq1
% start period.
startPer2 = 1 + floor((startPer1-1)*Freq2/Freq1);
% Find the latest freq2 period contained (at least partially) in freq1 end
% period.
endPer2 = ceil((endPer1)*Freq2/Freq1);
range2 = ...
    datcode(Freq2,startYear2,startPer2) : datcode(Freq2,endYear2,endPer2);

[xData2,flag] = xxInterpMatchEval(xData,n);
if ~flag
    warning('iris:tseries',...
        'Cannot compute ''%s'' interpolation for series with within-sample NaNs.',...
        Opt.method);
end
if strcmpi(Opt.method,'quadavg')
    xData2 = xData2*n;
end

xData2 = reshape(xData2,[size(xData2,1),xSize(2:end)]);
This.start = range2(1);
This.data = xData2;
This = mytrim(This);

end % xxInterpMatch().

%**************************************************************************
function [Y2,Flag] = xxInterpMatchEval(Y1,N)

[nObs,ny] = size(Y1);
Y2 = nan(nObs*N,ny);

t1 = (1 : N)';
t2 = (N+1 : 2*N)';
t3 = (2*N+1 : 3*N)';
M = [...
    N, sum(t1), sum(t1.^2);...
    N, sum(t2), sum(t2.^2);...
    N, sum(t3), sum(t3.^2);...
    ];

Flag = true;
for i = 1 : ny
    iY1 = Y1(:,i);
    [iSample,flagi] = getsample(iY1');
    Flag = Flag && flagi;
    if ~any(iSample)
        continue
    end
    iY1 = iY1(iSample);
    iNObs = numel(iY1);
    yy = [ iY1(1:end-2), iY1(2:end-1), iY1(3:end) ]';
    b = nan(3,iNObs);
    b(:,2:end-1) = M \ yy;
    iY2 = nan(N,iNObs);
    for t = 2 : iNObs-1
        iY2(:,t) = b(1,t)*ones(N,1) + b(2,t)*t2 + b(3,t)*t2.^2;
    end
    iY2(:,1) = b(1,2) + b(2,2)*t1 + b(3,2)*t1.^2;
    iY2(:,end) = b(1,end-1) + b(2,end-1)*t3 + b(3,end-1)*t3.^2;
    iSample = iSample(ones(1,N),:);
    iSample = iSample(:);
    Y2(iSample,i) = iY2(:);
end

end % interpMatchEval().
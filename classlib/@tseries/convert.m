function This = convert(This,ToFreq,varargin)
% convert  Convert tseries object to a different frequency.
%
% Syntax
% =======
%
%     Y = convert(X,NewFreq,...)
%     Y = convert(X,NewFreq,Range,...)
%
% Input arguments
% ================
%
% * `X` [ tseries ] - Input tseries object that will be converted to a new
% frequency, `freq`, aggregating or intrapolating the data.
%
% * `NewFreq` [ numeric | char ] - New frequency to which the input data
% will be converted: `1` or `'A'` for yearly, `2` or `'H'` for half-yearly,
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
% -Copyright (c) 2007-2014 IRIS Solutions Team.

if isempty(This)
    utils.warning('tseries', ...
        'Tseries object is empty, no conversion made.');
    return
end

if ~isempty(varargin) && isnumeric(varargin{1})
    Range = varargin{1};
    varargin(1) = [];
else
    Range = Inf;
end

%--------------------------------------------------------------------------

if isnan(This.start) && isempty(This.data)
    return
end

if isempty(Range)
    This = empty(This);
    return
end

% Resolve range, `Range` is then a vector of dates with no `Inf`.
if ~all(isinf(Range))
    This = resize(This,Range);
end
Range = specrange(This,Range);

ToFreq = xxRecogniseFreq(ToFreq);
if isempty(ToFreq)
    utils.error('tseries', ...
        'Cannot determine requested output frequency.');
end

fromFreq = datfreq(This.start);

call = [];
if fromFreq == ToFreq
    return
elseif fromFreq == 0
    % Conversion of daily series to lower frequencies.
    opt = passvalopt('tseries.convertaggregdaily',varargin{:});
    call = @xxAggreg;
elseif fromFreq == 52
    if ToFreq > 0
        % Conversion of weekly series to lower frequencies.
        opt = passvalopt('tseries.convertaggregdaily',varargin{:});
        call = @xxAggreg;
    end
elseif ToFreq ~= 0
    % Conversion of Y, Z, Q, B, or M series.
    if fromFreq > ToFreq
        % Aggregate.
        opt = passvalopt('tseries.convertaggreg',varargin{:});
        if ~isempty(opt.function)
            opt.method = opt.function;
        end
        call = @xxAggreg;
    elseif ToFreq ~= 0
        % Interpolate.
        opt = passvalopt('tseries.convertinterp',varargin{:});
        if any(strcmpi(opt.method,{'quadsum','quadavg'}))
            if ToFreq ~= 52
                % Quadratic interpolation matching sum or average.
                call = @xxInterpMatch;
            end
        else
            % Built-in interp1.
            call = @xxInterp;
        end
    end
end

if isa(call,'function_handle')
    This = call(This,Range,fromFreq,ToFreq,opt);
else
    utils.error('tseries:conversion', ...
        'Cannot convert tseries from freq=%g to freq=%g.', ...
        fromFreq,ToFreq);
end

end


% Subfunctions...


%**************************************************************************


function Freq = xxRecogniseFreq(Freq)
freqNum = [1,2,4,6,12,52];
if ischar(Freq)
    if ~isempty(Freq)
        freqLetter = 'yhqbmw';
        Freq = lower(Freq(1));
        if Freq == 'a'
            % Dual options for annual frequency: Y or A.
            Freq = 'y';
        elseif Freq == 's' || Freq == 'z'
            % Alternative options for semi-annual frequency: Z, S, H.
            Freq = 'h';
        end
        Freq = freqNum(Freq == freqLetter);
    else
        Freq = [];
    end
elseif ~any(Freq == freqNum)
    Freq = [];
end
end % xxRecogniseFreq()


%**************************************************************************


function X = first(X,varargin) %#ok<DEFNU>
X = X(1,:);
end % first()


%**************************************************************************


function X = last(X,varargin) %#ok<DEFNU>
X = X(end,:);
end % last().


%**************************************************************************


function This = xxAggreg(This,Range,FromFreq,ToFreq,Opt)
if ischar(Opt.method)
    Opt.method = str2func(Opt.method);
end

% Stretch the original range from the beginning of first year until the end
% of last year.
if FromFreq == 0
    [fromFirstYear,~,~] = datevec(Range(1));
    [fromLastYear,~,~] = datevec(Range(end));
    fromFirstDay = dd(fromFirstYear,1,1);
    fromLastDay = dd(fromLastYear,12,'end');
    Range = fromFirstDay : fromLastDay;
    if ToFreq == 52
        toDates = day2ww(Range);
    else
        [year,month] = datevec(Range);
        toDates = datcode(ToFreq,year,ceil(ToFreq*month/12));
    end
else
    fromFirstYear = dat2ypf(Range(1));
    fromLastYear = dat2ypf(Range(end));
    fromFirstDate = datcode(FromFreq,fromFirstYear,1);
    fromLastDate = datcode(FromFreq,fromLastYear,'end');
    Range = fromFirstDate : fromLastDate;
    toDates = convert(Range,ToFreq,'standinMonth=',Opt.standinmonth);
end

fromData = rangedata(This,Range);
fromSize = size(fromData);
fromData = fromData(:,:);
nCol = size(fromData,2);

% Treat missing observations in the input daily series.
for t = 1 : size(fromData,1)
    inx = isnan(fromData(t,:));
    if any(inx)
        switch Opt.missing
            case 'last'
                if t > 1
                    fromData(t,inx) = fromData(t-1,inx);
                else
                    fromData(t,inx) = NaN;
                end
            otherwise
                fromData(t,inx) = Opt.missing;
        end
    end
end

flToDates = floor(toDates);
nToPer = flToDates(end) - flToDates(1) + 1;

toStart = toDates(1);
toData = nan(0,nCol);
for t = flToDates(1) : flToDates(end)
    inx = t == flToDates;
    toX = nan(1,nCol);
    if any(inx)
        fromX = fromData(inx,:);
        for iCol = 1 : nCol
            iFromX = fromX(:,iCol);
            if Opt.ignorenan
                iFromX = iFromX(~isnan(iFromX));
            end
            if ~isequal(Opt.select,Inf)
                iFromX = iFromX(Opt.select);
            end
            if isempty(iFromX)
                toX(1,iCol) = NaN;
            else
                try
                    toX(1,iCol) = Opt.method(iFromX,1);
                catch %#ok<CTCH>
                    try %#ok<TRYNC>
                        toX(1,iCol) = Opt.method(iFromX);
                    end
                end
            end
        end
    end
    toData = [toData;toX]; %#ok<AGROW>
end

if length(fromSize) > 2
    toSize = fromSize;
    toSize(1) = nToPer;
    toData = reshape(toData,toSize);
end

This = replace(This,toData,toStart);

end % xxAggregDaily()


%**************************************************************************


function This = xxInterp(This,Range1,FromFreq,ToFreq,Opt)

[xData,Range1] = mygetdata(This,Range1);
xSize = size(xData);
xData = xData(:,:);

[startYear1,startPer1] = dat2ypf(Range1(1));
[endYear1,endPer1] = dat2ypf(Range1(end));

if ToFreq == 52
    startMonth1 = per2month(startPer1,FromFreq,'first');
    endMonth1 = per2month(endPer1,FromFreq,'last');
    startDay1 = datenum(startYear1,startMonth1,1);
    endDay1 = datenum(endYear1,endMonth1,eomday(endYear1,endMonth1));
    startDate2 = day2ww(startDay1);
    endDate2 = day2ww(endDay1);
    % Cut off the very first and very last week; it helps handle some weird
    % cases.
    startDate2 = startDate2 + 1;
    endDate2 = endDate2 - 1;
else
    startYear2 = startYear1;
    endYear2 = endYear1;
    % Find the earliest freq2 period contained (at least partially) in freq1
    % start period.
    startPer2 = 1 + floor((startPer1-1)*ToFreq/FromFreq);
    % Find the latest freq2 period contained (at least partially) in freq1 end
    % period.
    endper2 = ceil((endPer1)*ToFreq/FromFreq);
    startDate2 = datcode(ToFreq,startYear2,startPer2);
    endDate2 = datcode(ToFreq,endYear2,endper2);
end

range2 = startDate2 : endDate2;

grid1 = dat2dec(Range1,Opt.position);
grid2 = dat2dec(range2,Opt.position);
xData2 = interp1(grid1,xData,grid2,Opt.method,'extrap');
if size(xData2,1) == 1 && size(xData2,2) == length(range2)
    xData2 = xData2(:);
else
    xData2 = reshape(xData2,[size(xData2,1),xSize(2:end)]);
end
This.start = range2(1);
This.data = xData2;
This = mytrim(This);

end % xxInterp()


%**************************************************************************


function This = xxInterpMatch(This,Range1,FromFreq,ToFreq,Opt)
n = ToFreq/FromFreq;
if n ~= round(n)
    error('iris:tseris',...
        ['Source and target frequencies are incompatible ', ...
        'in ''%s'' interpolation.'],...
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
startPer2 = 1 + floor((startPer1-1)*ToFreq/FromFreq);
% Find the latest freq2 period contained (at least partially) in freq1 end
% period.
endPer2 = ceil((endPer1)*ToFreq/FromFreq);
firstDate2 = datcode(ToFreq,startYear2,startPer2);
lastDate2 = datcode(ToFreq,endYear2,endPer2);
range2 = firstDate2 : lastDate2;

[xData2,flag] = xxInterpMatchEval(xData,n);
if ~flag
    warning('iris:tseries',...
        ['Cannot compute ''%s'' interpolation for series ', ...
        'with in-sample NaNs.'],...
        Opt.method);
end
if strcmpi(Opt.method,'quadavg')
    xData2 = xData2*n;
end

xData2 = reshape(xData2,[size(xData2,1),xSize(2:end)]);
This.start = range2(1);
This.data = xData2;
This = mytrim(This);
end % xxInterpMatch()


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
end % interpMatchEval()

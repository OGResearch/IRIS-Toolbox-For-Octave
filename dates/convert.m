function NewDat = convert(Dat,ToFreq,varargin)
% convert   Convert dates to another frequency.
%
% Syntax
% =======
%
%     NewDat = convert(Dat,NewFreq,...)
%
% Input arguments
% ================
%
% * `Dat` [ numeric ] - IRIS serial date numbers that will be converted to
% the new frequency, `NewFreq`.
%
% * `NewFreq` [ `1` | `2` | `4` | `6` | `12` ] - New frequency to
% which the dates `d1` will be converted.
%
% Output arguments
% =================
%
% * `NewDat` [ numeric ] - IRIS serial date numbers representing the new
% frequency.
%
% Options
% ========
%
% * `'standinMonth='` [ numeric | `'last'` | *`1`* ] - Month that will be
% used to represent a certain period of time in low- to high-frequency
% conversions.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

% Parse options.
opt = passvalopt('dates.convert',varargin{:});

config = irisget();
if isequal(opt.standinmonth,'config')
   opt.standinmonth = config.standinmonth;
end

%--------------------------------------------------------------------------

fromFreq = datfreq(Dat);
ixZero = fromFreq == 0;
ixWeekly = fromFreq == 52;
ixRegular = ~ixZero & ~ixWeekly;

NewDat = nan(size(Dat));

if any(ixRegular(:))
    % Get year, period, and frequency of the original dates.
    [fromYear,fromPer,fromFreq] = dat2ypf(Dat(ixRegular));
    % First, convert the original period to a corresponding month.
    toMonth = per2month(fromPer,fromFreq,opt.standinmonth);
    % Then, convert the month to the corresponding period of the request
    % frequnecy.
    toPer = ceil(toMonth.*ToFreq./12);
    % Create the new serial date number.
    NewDat(ixRegular) = datcode(ToFreq,fromYear,toPer);
end

if any(ixWeekly(:))
    x = ww2day(Dat(ixWeekly),'Thursday');
    [toYear,toMonth] = datevec(x);
    toPer = ceil(toMonth.*ToFreq./12);
    NewDat(ixWeekly) = datcode(ToFreq,toYear,toPer);
end

end
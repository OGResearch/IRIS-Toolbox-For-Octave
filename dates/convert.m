function NewDat = convert(Dat,NewFreq,varargin)
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
% the new frequency, `newfreq`.
%
% * `NewFreq` [ `0` | `1` | `2` | `4` | `6` | `12` ] - New frequency to
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
% * `'standinMonth='` [ numeric | `'last'` | *`1`* ] - Which month will be
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

% Get year, period, and frequency of the original dates.
[y1,p1,f1] = dat2ypf(Dat);

% First, convert the original period to a corresponding month.
m = per2month(p1,f1,opt.standinmonth);

% Then, convert the month to the corresponding period of the request
% frequnecy.
p2 = ceil(m.*NewFreq./12);

% Create the new serial date number.
NewDat = datcode(NewFreq,y1,p2);

end
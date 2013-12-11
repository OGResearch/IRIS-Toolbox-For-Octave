function S = dat2str(Dat,varargin) 
% dat2str  Convert IRIS dates to cell array of strings.
%
% Syntax
% =======
%
%     S = dat2str(Dat,...)
%
% Input arguments
% ================
%
% * `Dat` [ numeric ] - IRIS serial date number(s).
%
% Output arguments
% =================
%
% * `S` [ cellstr ] - Cellstr with strings representing the input dates.
%
% Options
% ========
%
% * `'dateFormat='` [ char | cellstr | *'YYYYFP'* ] - Date format string,
% or array of format strings (possibly different for each date).
%
% * `'freqLetters='` [ char | *'YHQBM'* ] - Letters representing the five
% possible frequencies (annual,semi-annual,quarterly,bimontly,monthly).
%
% * `'months='` [ cellstr | *English names of months* ] - Cell array of
% twelve strings representing the names of months.
%
% * `'standinMonth='` [ numeric | 'last' | *1* ] - Which month will
% represent a lower-than-monthly-frequency date if month is part of the
% date format string.
%
% Description
% ============
%
% The date format string can include any combination of the following
% fields:
%
% * `'Y'` - Year.
%
% * `'YYYY'` - Four-digit year.
%
% * `'YY'` - Two-digit year.
%
% * `'P'` - Period within the year (half-year, quarter, bi-month, month).
%
% * `'PP'` - Two-digit period within the year.
%
% * `'R'` - Upper-case roman numeral for the period within the year.
%
% * `'r'` - Lower-case roman numeral for the period within the year.
%
% * `'M'` - Month numeral.
%
% * `'MM'` - Two-digit month numeral.
%
% * `'MMMM'`, `'Mmmm'`, `'mmmm'` - Case-sensitive name of month.
%
% * `'MMM'`, `'Mmm'`, `'mmm'` - Case-sensitive three-letter abbreviation of
% month.
%
% * `'F'` - Upper-case letter representing the date frequency.
%
% * `'f'` - Lower-case letter representing the date frequency.
%
% * `'EE'` - Two-digit end-of-month day; stand-in month used for
% non-monthly dates.
%
% * `'E'` - End-of-month day; stand-in month used for non-monthly dates.
%
% * `'WW'` - Two-digit end-of-month workday; stand-in month used for
% non-monthly dates.
%
% * `'W'` - End-of-month workday; stand-in month used for non-monthly dates.
%
% * `'DD'` - Two-digit day numeral; daily dates only.
%
% * `'D'` - Day numeral; daily dates only.
%
% To get some of the above letters printed literally in the date string,
% use a percent sign as an escape character, i.e. '%Y', etc.
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

if nargin > 1 && isstruct(varargin{1})
    opt = varargin{1};
    config = irisget();
else
    % Parse options.
    opt = passvalopt('dates.dat2str',varargin{1:end});
    % Run dates/datdefaults to substitute the default (irisget) date
    % format options for 'config'.
    [opt,config] = datdefaults(opt);
end

%--------------------------------------------------------------------------

if ischar(opt.dateformat)
    opt.dateformat = {opt.dateformat};
end

[year,per,freq] = dat2ypf(Dat);

yeard = nan(size(year));
perd = nan(size(year));
day = nan(size(year));
inx = freq == 0;
if any(inx)
    [yeard(inx),perd(inx),day(inx)] = datevec(Dat(inx));
end

S = cell(size(year));
n = numel(year);

for k = 1 : n
    dateFmt = opt.dateformat{min(k,end)};
    isDaily = false;
    if strncmp(dateFmt,'$',1)
        if freq(k) == 0
            dateFmt(1) = '';
            isDaily = true;
            year(k) = yeard(k);
            per(k) = perd(k);
        else
            utils.error('dates', ...
                'Cannot convert other than daily dates to Matlab date string.');
        end
    end
    S{k} = xxBuildString(year(k),per(k),day(k),freq(k),dateFmt,isDaily, ...
        opt.freqletters,opt.months,opt.standinmonth, ...
        config.highcharcode);
end

end

% Subfunctions.

%**************************************************************************
function s = xxBuildString(Year,Per,Day,Freq,DateFmt,IsDaily, ...
    FreqLetters,Months,StandInMonth,Offset)

if Freq == 0 && ~IsDaily
    varYear = '';
    longYear = '';
    shortYear = '';
else
    varYear = sprintf('%g',Year);
    longYear = sprintf('%04g',Year);
    if length(longYear) > 2
        shortYear = longYear(end-1:end);
    else
        shortYear = longYear;
    end
end

if IsDaily
    varDay = sprintf('%g',Day);
    longDay = sprintf('%02g',Day);
else
    varDay = '';
    longDay = '';
end

switch Freq
    case 0
        if IsDaily
            freqLetter = 'D';
            shortArabPer = sprintf('%g',Per);
            longArabPer = sprintf('%02g',Per);
            numMonth = Per;
            romanPer = '';
        else
            freqLetter = '';
            shortArabPer = sprintf('%g',Per);
            longArabPer = sprintf('%02g',Per);
            numMonth = NaN;
            romanPer = '';
        end
    case 1
        freqLetter = FreqLetters(1);
        shortArabPer = '';
        longArabPer = '';
        numMonth = per2month(Per,1,StandInMonth);
        romanPer = '';
    case 2
        freqLetter = FreqLetters(2);
        shortArabPer = sprintf('%g',Per);
        longArabPer = sprintf('%02g',Per);
        numMonth = per2month(Per,2,StandInMonth);
        romanPer = xxRoman(Per);
    case 4
        freqLetter = FreqLetters(3);
        shortArabPer = sprintf('%g',Per);
        longArabPer = sprintf('%02g',Per);
        numMonth = per2month(Per,4,StandInMonth);
        romanPer = xxRoman(Per);
    case 6
        freqLetter = FreqLetters(4);
        shortArabPer = sprintf('%g',Per);
        longArabPer = sprintf('%02g',Per);
        numMonth = per2month(Per,6,StandInMonth);
        romanPer = xxRoman(Per);
    case 12
        freqLetter = FreqLetters(5);
        shortArabPer = sprintf('%02g',Per);
        longArabPer = sprintf('%02g',Per);
        numMonth = Per;
        romanPer = xxRoman(Per);
    otherwise
        freqLetter = '?';
        shortArabPer = sprintf('%g',Per);
        longArabPer = sprintf('%02g',Per);
        numMonth = NaN;
        romanPer = '';
end

if isempty(numMonth) || isnan(numMonth) || ~isnumeric(numMonth)
    longMonth = '';
    shortMonth = '';
else
    longMonth = Months{numMonth};
    shortMonth = longMonth(1:min([3,end]));
end

try
    x = eomday(Year,numMonth);
    varEndOfMonth = sprintf('%g',x);
    longEndOfMonth = sprintf('%02g',x);
    w = weekday(datenum(Year,numMonth,x));
    if w == 1
        x = x - 2;
    elseif w == 7
        x = x - 1;
    end
    varEndOfMonthW = sprintf('%g',x);
    longEndOfMonthW = sprintf('%02g',x);    
catch
    varEndOfMonth = '';
    longEndOfMonth = '';
    varEndOfMonthW = '';
    longEndOfMonthW = '';
end    

romanMonth = xxRoman(numMonth);
varNumericMonth = sprintf('%g',numMonth);
numMonth = sprintf('%02g',numMonth);

subs = { ...
    '%Y','Y'; ...
    '%P','P'; ...
    '%F','F'; ...
    '%f','f'; ...
    '%R','R'; ...
    '%r','r'; ...
    '%Q','Q'; ...
    '%q','q'; ...
    '%M','M'; ...
    '%m','m'; ...
    '%E','E'; ...
    '%W','W'; ...
    '%D','D'; ...
    'YYYY',longYear; ...
    'YY',shortYear; ...
    'Y',varYear; ...
    'PP',longArabPer; ...
    'P',shortArabPer; ...
    'Q',romanMonth; ...
    'q',lower(romanMonth); ...
    'R',romanPer; ...
    'r',lower(romanPer); ...
    'F',upper(freqLetter); ...
    'f',lower(freqLetter); ...
    'Mmmm',longMonth; ...
    'Mmm',shortMonth; ...
    'mmmm',lower(longMonth); ...
    'mmm',lower(shortMonth); ...
    'MMMM',upper(longMonth); ...
    'MMM',upper(shortMonth); ...
    'MM',numMonth; ...
    'mm',numMonth; ...
    'M',varNumericMonth; ...
    'm',varNumericMonth; ...
    'EE',longEndOfMonth; ...
    'E',varEndOfMonth; ...
    'WW',longEndOfMonthW; ...
    'W',varEndOfMonthW; ...
    'DD',longDay; ...
    'D',varDay; ...
    };

s = DateFmt;

for i = 1 : size(subs,1)
    if ismatlab
        cCode = Offset+i;
    else
        cCode = highCharCode2utf8(Offset+i);
    end
    s = strrep(s,subs{i,1},char(cCode));
end

for i = 1 : size(subs,1)
    if ismatlab
        cCode = Offset+i;
    else
        cCode = highCharCode2utf8(Offset+i);
    end
    s = strrep(s,char(cCode),subs{i,2});
end

end % xxBuildString().

%**************************************************************************
function x = xxRoman(x)
% xxRoman  Convert month to a roman numeral string.

romans = { ...
    'I','II','III','IV','V','VI', ...
    'VII','VIII','IX','X','XI','XII', ...
    };
try
    x = romans{x};
catch %#ok<CTCH>
    x = '';
end

end % xxRoman().
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
% * `'standinMonth='` [ numeric | `'last'` | `*1*` ] - Which month will
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
% * `'P'` - Period within the year (half-year, quarter, bi-month, month,
% week).
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
% * `'DD'` - Two-digit day numeral; daily and weekly dates only.
%
% * `'D'` - Day numeral; daily and weekly dates only.
%
% To get some of the above letters printed literally in the date string,
% use a percent sign as an escape character, i.e. '%Y', etc.
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

if ~isempty(varargin) && isstruct(varargin{1})
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

S = cell(size(year));
n = numel(year);

for k = 1 : n
    if k <= length(opt.dateformat)
        dateFmt = opt.dateformat{k};
        [is,ixSubs] = xxIsDateFmt(dateFmt);
    end
        
    if strncmp(dateFmt,'$',1)
        % Calendar dates (daily, weekly)
        %--------------------------------
        dateFmt(1) = '';
        if freq(k) == 0
            [year(k),month,day] = datevec(Dat(k));
        elseif freq(k) == 52
            d = ww2day(Dat(k));
            [year(k),month,day] = datevec(d);
        else
            utils.error('dates', ...
                ['Cannot convert other than daily and weekly dates ', ...
                'to calendar date string.']);
        end
        x = xxCalendarDate(year(k),month,day,freq(k),is,opt);
    else
        % Regular IRIS dates
        %--------------------
        x = xxIrisDate(Dat(k),year(k),per(k),freq(k),is,opt);
    end
    S{k} = xxReplace(dateFmt,x,ixSubs,config.highcharcode);
end

end


% Subfunctions...


%**************************************************************************
function X = xxCalendarDate(Year,Month,Day,Freq,Is,Opt)

freqLetters = Opt.freqletters;
monthNames = Opt.months;

X = xxEmptyStruct();

if Is.year
    X = xxYear(X,Year);
end

if Is.month
    X = xxMonth(X,Month,monthNames);
end

if Is.eom
    X = xxEndOfMonthDay(X,Year,Month);
end

if Is.day
    X = xxDay(X,Day);
end

switch Freq
    case 0
        X.freqLetter = 'D';
    case 52
        X.freqLetter = freqLetters(6);
end

end % xxCalendarDate()


%**************************************************************************
function X = xxIrisDate(Dat,Year,Per,Freq,Is,Opt)

freqLetters = Opt.freqletters;
monthNames = Opt.months;
standInMonth = Opt.standinmonth;

X = xxEmptyStruct();

if Freq ~= 0 && Is.year
    X = xxYear(X,Year);
end

switch Freq
    case 0
        X.freqLetter = '';
        X.shortArabPer = sprintf('%g',Per);
        X.longArabPer = sprintf('%02g',Per);
        X.romanPer = '';
    case 1
        X.freqLetter = freqLetters(1);
        X.shortArabPer = '';
        X.longArabPer = '';
        X.romanPer = '';
        month = per2month(Per,1,standInMonth);
    case 2
        X.freqLetter = freqLetters(2);
        X.shortArabPer = sprintf('%g',Per);
        X.longArabPer = sprintf('%02g',Per);
        X.romanPer = xxRoman(Per);
        month = per2month(Per,2,standInMonth);
    case 4
        X.freqLetter = freqLetters(3);
        X.shortArabPer = sprintf('%g',Per);
        X.longArabPer = sprintf('%02g',Per);
        X.romanPer = xxRoman(Per);
        month = per2month(Per,4,standInMonth);
    case 6
        X.freqLetter = freqLetters(4);
        X.shortArabPer = sprintf('%g',Per);
        X.longArabPer = sprintf('%02g',Per);
        X.romanPer = xxRoman(Per);
        month = per2month(Per,6,standInMonth);
    case 12
        X.freqLetter = freqLetters(5);
        X.shortArabPer = sprintf('%02g',Per);
        X.longArabPer = sprintf('%02g',Per);
        X.romanPer = xxRoman(Per);
        month = Per;
    case 52
        X.freqLetter = freqLetters(6);
        X.shortArabPer = sprintf('%02g',Per);
        X.longArabPer = sprintf('%02g',Per);
        X.romanPer = xxRoman(Per);
        % Month that contains Thursday in this week.
        [~,month] = datevec(ww2day(Dat)+3);
    otherwise
        X.freqLetter = '?';
        X.shortArabPer = sprintf('%g',Per);
        X.longArabPer = sprintf('%02g',Per);
        X.romanPer = '';
        month = NaN;
end

if Is.month
    X = xxMonth(X,month,monthNames);
end

if Is.eom
    X = xxEndOfMonthDay(X,Year,month);
end

end % xxIrisDate()


%**************************************************************************
function S = xxReplace(DateFmt,X,IxSubs,Offset)

subs = xxDateFormatSubs(X);
S = DateFmt;

for i = find(IxSubs)
    S = strrep(S,subs{i,1},char(Offset+i));
end

for i = find(IxSubs)
    S = strrep(S,char(Offset+i),subs{i,2});
end

end % xxReplace()


%**************************************************************************
function X = xxYear(X,Year)
    X.varYear = sprintf('%g',Year);
    X.longYear = sprintf('%04g',Year);
    if length(X.longYear) > 2
        X.shortYear = X.longYear(end-1:end);
    else
        X.shortYear = X.longYear;
    end
end % xxYear()


%**************************************************************************
function X = xxEndOfMonthDay(X,Year,Month)
try
    d = eomday(Year,Month);
    X.varEndOfMonth = sprintf('%g',d);
    X.longEndOfMonth = sprintf('%02g',d);
    w = weekday(datenum(Year,Month,d));
    if w == 1
        d = d - 2;
    elseif w == 7
        d = d - 1;
    end
    X.varEndOfMonthW = sprintf('%g',d);
    X.longEndOfMonthW = sprintf('%02g',d);
catch
    X.varEndOfMonth = '';
    X.longEndOfMonth = '';
    X.varEndOfMonthW = '';
    X.longEndOfMonthW = '';
end
end % xxEndOfMonth()


%**************************************************************************
function X = xxMonth(X,Month,MonthNames)
if isempty(Month) || isnan(Month) || ~isnumeric(Month)
    X.longMonth = '';
    X.shortMonth = '';
else
    X.longMonth = MonthNames{Month};
    X.shortMonth = X.longMonth(1:min(3,end));
end
X.romanMonth = xxRoman(Month);
X.varNumMonth = sprintf('%g',Month);
X.numMonth = sprintf('%02g',Month);
end % xxMonth()


%**************************************************************************
function X = xxDay(X,Day)
if ~isnan(Day)
    X.varDay = sprintf('%g',Day);
    X.longDay = sprintf('%02g',Day);
else
    X.varDay = '';
    X.longDay = '';
end
end % xxDay()


%**************************************************************************
function X = xxEmptyStruct()

X = struct();

X.longYear = '';
X.shortYear = '';
X.varYear = '';

X.longArabPer = '';
X.shortArabPer = '';
X.romanPer = '';

X.romanMonth = '';
X.longMongth = '';
X.shortMonth = '';
X.longMonth = '';
X.numMonth = '';
X.varNumMonth = '';
X.longEndOfMonth = '';
X.varEndOfMonth = '';
X.longEndOfMonthW = '';
X.varEndOfMonthW = '';

X.longDay = '';
X.varDay = '';

X.freqLetter = '';

end % xxEmptyStruct()

%**************************************************************************
function X = xxRoman(X)
% xxRoman  Convert month to a roman numeral string.
romans = { ...
    'I','II','III','IV','V','VI', ...
    'VII','VIII','IX','X','XI','XII', ...
    };
try
    X = romans{X};
catch %#ok<CTCH>
    X = '';
end
end % xxRoman()


%**************************************************************************
function S = xxDateFormatSubs(X)

try
    X; %#ok<VUNUS>
catch
    X = xxEmptyStruct();
end

S = { ...
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
    'YYYY',X.longYear; ...
    'YY',X.shortYear; ...
    'Y',X.varYear; ...
    'PP',X.longArabPer; ...
    'P',X.shortArabPer; ...
    'Q',X.romanMonth; ...
    'q',lower(X.romanMonth); ...
    'R',X.romanPer; ...
    'r',lower(X.romanPer); ...
    'F',upper(X.freqLetter); ...
    'f',lower(X.freqLetter); ...
    'Mmmm',X.longMonth; ...
    'Mmm',X.shortMonth; ...
    'mmmm',lower(X.longMonth); ...
    'mmm',lower(X.shortMonth); ...
    'MMMM',upper(X.longMonth); ...
    'MMM',upper(X.shortMonth); ...
    'MM',X.numMonth; ...
    'mm',X.numMonth; ...
    'M',X.varNumMonth; ...
    'm',X.varNumMonth; ...
    'EE',X.longEndOfMonth; ...
    'E',X.varEndOfMonth; ...
    'WW',X.longEndOfMonthW; ...
    'W',X.varEndOfMonthW; ...
    'DD',X.longDay; ...
    'D',X.varDay; ...
    };

end % xxDateFormatSubs()


%**************************************************************************
function [Is,IxSubs] = xxIsDateFmt(DateFmt)

Is = struct();
Is.year = any(DateFmt == 'Y');
Is.eom = any(DateFmt == 'E');
Is.month = any(DateFmt == 'M') || any(DateFmt == 'm');
Is.day = any(DateFmt == 'D') || any(DateFmt == 'M');

subs = xxDateFormatSubs();
nSubs = size(subs,1);
IxSubs = false(1,nSubs);
for i = 1 : nSubs
    IxSubs(i) = ~isempty(strfind(DateFmt,subs{i,1}));
end

end % xxIsDateFmt()

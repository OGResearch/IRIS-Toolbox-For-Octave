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
% * `'Y='` - Year.
%
% * `'YYYY='` - Four-digit year.
%
% * `'YY='` - Two-digit year.
%
% * `'P='` - Period within the year (half-year, quarter, bi-month, month).
%
% * `'PP='` - Two-digit period within the year.
%
% * `'R='` - Upper-case roman numeral for the period within the year.
%
% * `'r='` - Lower-case roman numeral for the period within the year.
%
% * `'M='` - Month numeral.
%
% * `'MM='` - Two-digit month numeral.
%
% * `'MMMM='`, `'Mmmm'`, `'mmmm'` - Case-sensitive name of month.
%
% * `'MMM='`, `'Mmm'`, `'mmm'` - Case-sensitive three-letter abbreviation of
% month.
%
% * `'F='` - Upper-case letter representing the date frequency.
%
% * `'f='` - Lower-case letter representing the date frequency.
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
nDateFormat = numel(opt.dateformat);

[year,per,freq] = dat2ypf(Dat);
S = cell(size(year));
n = numel(year);

for k = 1 : n
    if k <= nDateFormat
        dateformat = opt.dateformat{k};
    end
    if strncmp(dateformat,'$',1)
        if freq(k) == 0
            S{k} = datestr(per(k),dateformat(2:end));
        else
            utils.error('dates', ...
                'Cannot convert other than daily dates to Matlab date string.');
        end
    else
        S{k} = xxBuildString(year(k),per(k),freq(k),dateformat, ...
            opt.freqletters,opt.months,opt.standinmonth, ...
            config.highcharcode);
    end
end

end

% Subfunctions.

%**************************************************************************
function s = xxBuildString(Year,Per,Freq,DateFmt, ...
    FreqLetters,Months,StandInMonth,Offset)

if Freq == 0
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

switch Freq
    case 0
        freqLetter = '';
        shortArabPer = sprintf('%g',Per);
        longArabPer = sprintf('%02g',Per);
        numericMonth = NaN;
        romanPer = '';
    case 1
        freqLetter = FreqLetters(1);
        shortArabPer = '';
        longArabPer = '';
        numericMonth = per2month(Per,1,StandInMonth);
        romanPer = '';
    case 2
        freqLetter = FreqLetters(2);
        shortArabPer = sprintf('%g',Per);
        longArabPer = sprintf('%02g',Per);
        numericMonth = per2month(Per,2,StandInMonth);
        romanPer = xxRoman(Per);
    case 4
        freqLetter = FreqLetters(3);
        shortArabPer = sprintf('%g',Per);
        longArabPer = sprintf('%02g',Per);
        numericMonth = per2month(Per,4,StandInMonth);
        romanPer = xxRoman(Per);
    case 6
        freqLetter = FreqLetters(4);
        shortArabPer = sprintf('%g',Per);
        longArabPer = sprintf('%02g',Per);
        numericMonth = per2month(Per,6,StandInMonth);
        romanPer = xxRoman(Per);
    case 12
        freqLetter = FreqLetters(5);
        shortArabPer = sprintf('%02g',Per);
        longArabPer = sprintf('%02g',Per);
        numericMonth = Per;
        romanPer = xxRoman(Per);
    otherwise
        freqLetter = '?';
        shortArabPer = sprintf('%g',Per);
        longArabPer = sprintf('%02g',Per);
        numericMonth = NaN;
        romanPer = '';
end

if isempty(numericMonth) || isnan(numericMonth) || ~isnumeric(numericMonth)
    longMonth = '';
    shortMonth = '';
else
    longMonth = Months{numericMonth};
    shortMonth = longMonth(1:min([3,end]));
end
romanMonth = xxRoman(numericMonth);
varNumericMonth = sprintf('%g',numericMonth);
numericMonth = sprintf('%02g',numericMonth);

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
    'MM',numericMonth; ...
    'mm',numericMonth; ...
    'M',varNumericMonth; ...
    'm',varNumericMonth; ...
    };

s = DateFmt;
for i = 1 : size(subs,1)
    s = strrep(s,subs{i,1},char(Offset+i));
end
for i = 1 : size(subs,1)
    s = strrep(s,char(Offset+i),subs{i,2});
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
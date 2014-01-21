function [S,field] = dat2str(Dat,varargin)
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
% There are two types of date strings in IRIS: regular and calendar.
% Regular date strings can be printed for dates with yearly, half-yearly,
% quarterly, bimonthly, monthly, weekly, and indeterminate frequencies.
% Calendar date strings can be printed for dates with weekly and daily
% frequencies. Date formats for calendar date strings must start with a
% dollar sign, `$`. 
%
% Regular date strings
% ---------------------
%
% Regular date formats can include any combination of the following
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
% * `'Q'` - Upper-case roman numeral for the month or stand-in month.
%
% * `'r'` - Lower-case roman numeral for the month or stand-in month.
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
% Calendar date strings
% ----------------------
%
% Calendar date formats must start with a dollar sign, `$`, and can include
% any combination of the following fields:
%
% * `'Y'` - Year.
%
% * `'YYYY'` - Four-digit year.
%
% * `'YY'` - Two-digit year.
%
% * `'DD'` - Two-digit day numeral; daily and weekly dates only.
%
% * `'D'` - Day numeral; daily and weekly dates only.
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
% * `'Q'` - Upper-case roman numeral for the month.
%
% * `'r'` - Lower-case roman numeral for the month.
%
% * `'DD'` - Two-digit day numeral.
%
% * `'D'` - Day numeral.
%
% Escaping control letters
% -------------------------
%
% To get the format letters printed literally in the date string, use a
% percent sign as an escape character: `'%Y'`, `'%P'`, `'%F'`, `'%f'`,
% `'%M'`, `'%m'`, `'%R'`, `'%r'`, `'%Q'`, `'%q'`, `'%D'`, `'%E'`, `'%D'`.
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

if ~isempty(varargin) && isstruct(varargin{1})
    opt = varargin{1};
else
    % Parse options.
    opt = passvalopt('dates.dat2str',varargin{1:end});
    % Run dates/datdefaults to substitute the default (irisget) date
    % format options for the string `'config'`.
    opt = datdefaults(opt);
end

upperRomans = { ...
    'I','II','III','IV','V','VI', ...
    'VII','VIII','IX','X','XI','XII', ...
    };
lowerRomans = lower(upperRomans);

%--------------------------------------------------------------------------

if ischar(opt.dateformat)
    opt.dateformat = {opt.dateformat};
end

[year,per,freq] = dat2ypf(Dat);

isYearly = freq == 1;
per(isYearly) = NaN;

% Matlab serial date numbers (daily or weekly dates only), calendar years,
% months, and days.
isZero = freq == 0;
isWeekly = freq == 52;
isMsd = isZero | isWeekly;
msd = nan(size(Dat));
cyear = nan(size(Dat)); 
cmonth = nan(size(Dat));
cday = nan(size(Dat));
if any(isMsd(:))
    year(isZero) = NaN;
    msd(isZero) = Dat(isZero);
    msd(isWeekly) = ww2day(Dat(isWeekly));
    [cyear(isMsd),cmonth(isMsd),cday(isMsd)] = datevec(msd(isMsd));
end

S = cell(size(year));
S(:) = {''};
nDat = numel(year);
nFmt = numel(opt.dateformat);

for i = 1 : nDat
    
    if i <= nFmt
        isMonthNeeded = false;
        isCalendar = false;
        fmt = opt.dateformat{i};
        field = {};
        doBreakDownFmt();
        nField = length(field);
    end
    
    subs = cell(1,nField);
    subs(:) = {''};
    
    dat = Dat(i);
    y = year(i);
    p = per(i);
    f = freq(i);
    cy = cyear(i);
    cm = cmonth(i);
    cd = cday(i);
    s = msd(i);
    m = NaN;
    
    if isMonthNeeded
        % Calculate non-calendar month.
        m = doCalculateMonth();
    end

    for j = 1 : nField
       switch field{j}(1)
           case 'Y'
               if isCalendar
                   subs{j} = doYear(cy);
               else
                   subs{j} = doYear(y);
               end
           case {'M','m','Q','q'}
               if isCalendar
                   subs{j} = doMonth(cm);
                   
               else
                   subs{j} = doMonth(m);
               end
           case {'P','R','r'}
               subs{j} = doPer();
           case {'F','f'}
               subs{j} = doFreqLetter();
           case 'D'
               if isCalendar
                   subs{j} = doDay();
               end
           case 'E'
               if isCalendar
                   subs{j} = doEom(cy,cm);
               else
                   subs{j} = doEom(y,m);
               end
           case 'W'
               if isCalendar
                   subs{j} = doEomW(cy,cm);
               else
                   subs{j} = doEomW(y,m);
               end
               
       end
    end
    
    S{i} = sprintf(fmt,subs{:});
end


% Nested functions...


%**************************************************************************
    function doBreakDownFmt()
        
        isCalendar = strncmp(fmt,'$',1);
        if isCalendar
            fmt(1) = '';
        end
        
        fmt = regexprep(fmt,'%([YPFfRrQqMmEWD])','&$1');
        
        ptn = ['(?<!&)(',...
            'YYYY|YY|Y|', ...
            'PP|P|', ...
            'R|r|', ...
            'F|f|', ...
            'Mmmm|Mmm|mmmm|mmm|MMMM|MMM|MM|M', ...
            'Q|q|', ...
            'EE|E|WW|W|', ...
            'DD|D', ...
            ')'];
        
        replaceFunc = @doReplace; %#ok<NASGU>
        
        while true
            found = false;
            fmt = regexprep(fmt,ptn,'${replaceFunc($1)}','once');
            if ~found
                break
            end
        end
        
        fmt = regexprep(fmt,'&([YPFfRrQqMmEWD])','$1');
        
        function C = doReplace(C0)
            found = true;
            C = '%s';
            field{end+1} = C0;
            if ~isCalendar && any(C0(1) == 'MQqEW')
                isMonthNeeded = true;
            end
        end
    end % doIsFmt()


%**************************************************************************
    function Subs = doYear(Y)
        Subs = '';
        if ~isfinite(Y)
            return
        end
        switch field{j}
            case 'YYYY'
                Subs = sprintf('%04g',Y);
            case 'YY'
                Subs = sprintf('%04g',Y);
                if length(Subs) > 2
                    Subs = Subs(end-1:end);
                end
            case 'Y'
                Subs = sprintf('%g',Y);
        end
    end % doYear()


%**************************************************************************
    function Subs = doPer()
        Subs = '';
        if ~isfinite(p)
            return
        end
        switch field{j}
            case 'PP'
                Subs = sprintf('%02g',p);
            case 'P'
                if f < 10
                    Subs = sprintf('%g',p);
                else
                    Subs = sprintf('%02g',p);
                end
            case 'R'
                try %#ok<TRYNC>
                    Subs = upperRomans{p};
                end
            case 'r'
                try %#ok<TRYNC>
                    Subs = lowerRomans{p};
                end
        end
    end % doPer()


%**************************************************************************
    function Subs = doMonth(M)
        Subs = '';
        if ~isfinite(M)
            return
        end
        switch field{j}
            case {'MMMM','Mmmm','MMM','Mmm'}
                Subs = opt.months{M};
                if field{j}(1) == 'M'
                    Subs(1) = upper(Subs(1));
                else
                    Subs(1) = lower(Subs(1));
                end
                if field{j}(end) == 'M'
                    Subs(2:end) = upper(Subs(2:end));
                else
                    Subs(2:end) = lower(Subs(2:end));
                end
                if length(field{j}) == 3
                    Subs = Subs(1:3);
                end
            case 'MM'
                Subs = sprintf('%02g',M);
            case 'M'
                Subs = sprintf('%g',M);
            case 'Q'
                try %#ok<TRYNC>
                    Subs = upperRomans{M};
                end
            case 'q'
                try %#ok<TRYNC>
                    Subs = lowerRomans{M};
                end
        end
    end % doMonth()


%**************************************************************************
    function Subs = doDay()
        Subs = '';
        if ~isfinite(cd)
            return
        end
        switch field{j}
            case 'DD'
                Subs = sprintf('%02g',cd);
            case 'D'
                Subs = sprintf('%g',cd);
        end
    end

%**************************************************************************
    function Subs = doEom(Y,M)
        Subs = '';
        if ~isfinite(Y) || ~isfinite(M)
            return
        end
        e = eomday(Y,M);
        switch field{j}
            case 'E'
                Subs = sprintf('%g',e);
            case 'EE'
                Subs = sprintf('%02g',e);
        end
    end % doEom()



%**************************************************************************
    function Subs = doEomW(Y,M)
        Subs = '';
        if ~isfinite(Y) || ~isfinite(M)
            return
        end
        e = eomday(Y,M);
        w = weekday(datenum(Y,M,e));
        if w == 1
            e = e - 2;
        elseif w == 7
            e = e - 1;
        end
        switch field{j}
            case 'W'
                Subs = sprintf('%g',e);
            case 'WW'
                Subs = sprintf('%02g',e);
        end
    end % doEomW()


%**************************************************************************
    function M = doCalculateMonth()
        % Non-calendar month.
        M = NaN;
        switch f
            case {1,2,4,6}
                M = per2month(p,f,opt.standinmonth);
            case 12
                M = p;
            case 52
                % Non-calendar month of a weekly date is the month that contains Thursday.
                [~,M] = datevec(s+3);
        end
    end % doCalculateMonth


%**************************************************************************
    function Subs = doFreqLetter()
        Subs = '';
        switch f
            case 1
                Subs = opt.freqletters(1);
            case 2
                Subs = opt.freqletters(2);
            case 4
                Subs = opt.freqletters(3);
            case 6
                Subs = opt.freqletters(4);
            case 12
                Subs = opt.freqletters(5);
            case 52
                Subs = opt.freqletters(6);
        end
        if isequal(field{j},'f')
            Subs = lower(Subs);
        end
    end % doFreqLetter()


end
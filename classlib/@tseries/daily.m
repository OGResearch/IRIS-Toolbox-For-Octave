function daily(This)
% DAILY   Calendar view of a daily tseries object.
%
% Syntax
% =======
%
%     daily(X)
%
% Input arguments
% ================
%
% * `X` [ tseries ] - Tseries object with indeterminate frequency whose
% date ticks will be interpreted as Matlab serial date numbers.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.


if datfreq(This.start) ~= 0
    utils.error('tseries', ...
        ['Function DAILY can be used only on series ', ...
        'with indeterminate frequency.']);
end

%--------------------------------------------------------------------------

disp(This,'',@xxDisp2dDaily);

end


% Subfunctions...


%**************************************************************************
function X = xxDisp2dDaily(Start,Data,Tab,Sep,Num2StrFunc)

[nPer,nCol] = size(Data);
[startYear,startMonth,startDay] = datevec(Start);
[endYear,endMonth,endDay] = datevec(Start + nPer - 1);

% Pad missing observations at the beginning of the first month
% and at the end of the last month with NaNs.
tmp = eomday(endYear,endMonth);
Data = [nan(startDay-1,nCol);Data;nan(tmp-endDay,nCol)];

% Start-date and end-date of the calendar matrixt.
% startdate = datenum(startyear,startmonth,1);
% enddate = datenum(endyear,endmonth,tmp);

year = startYear : endYear;
nYear = length(year);
year = year(ones(1,12),:);
year = year(:);

month = 1 : 12;
month = transpose(month(ones([1,nYear]),:));
month = month(:);

year(1:startMonth-1) = [];
month(1:startMonth-1) = [];
year(end-(12-endMonth)+1:end) = [];
month(end-(12-endMonth)+1:end) = [];
nPer = length(month);

lastDay = eomday(year,month);
X = [];
for t = 1 : nPer
    tmp = nan(nCol,31);
    tmp(:,1:lastDay(t)) = transpose(Data(1:lastDay(t),:));
    X = [X;tmp]; %#ok<AGROW>
    Data(1:lastDay(t),:) = [];
end

% Date string.
rowStart = datenum(year,month,1);
nRow = length(rowStart);
dates = cell(1,1 + nCol*nRow);
dates(:) = {''};
dates(2:nCol:end) = dat2str(rowStart,'dateFormat=',['$Mmm-YYYY',Sep]);
dates = char(dates);

% Data string.
divider = '    ';
divider = divider(ones(size(X,1)+1,1),:);
dataStr = '';
for i = 1 : 31
    c = Num2StrFunc(X(:,i));
    dataStr = [dataStr, ...
        strjust(char(sprintf('[%g]',i),c),'right')]; %#ok<AGROW>
    if i < 31
        dataStr = [dataStr,divider]; %#ok<AGROW>
    end
end

repeat = ones(size(dates,1),1);
X = [Tab(repeat,:),dates,dataStr];

end % xxCalendar()
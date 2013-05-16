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

% Display header.
strfun.loosespace();
mydispheader(This);

% Re-arrange data into a 2D matrix.
This.data = This.data(:,:);

% Display data, one month per row
[x,rowStart] = xxCalendar(This);
output = ' ';
blanks(1:size(This.data,2)-1) = {' '};
for i = 1 : length(rowStart)
    output = char(output,datestr(rowStart(i),'    mmm-YYYY:'),blanks{:});
end
output = strjust(output,'right');
divider = ' ';
divider = divider(ones([size(output,1),1]));
output = [output,divider(:,[1,1])];
for i = 1 : 31
    tmp = strjust(char(sprintf('[%g]',i),num2str(x(:,i))),'right');
    output = [output,tmp]; %#ok<AGROW>
    if i < 31
        output = [output,divider(:,[1,1,1,1])]; %#ok<AGROW>
    end
end
disp(output);

% Display comment.
disp(This.Comment);

% [startyear,startmonth,startday] = datevec(this.start);

end

% Subfunctions.

%**************************************************************************
function [x,RowStart] = xxCalendar(This)

if isnan(This.start) || isempty(This.data)
    x = [];
    RowStart = NaN;
    return
end

[nPer,ncol] = size(This.data);
[startYear,startMonth,startDay] = datevec(This.start);
[endYear,endMonth,endDay] = datevec(This.start + nPer - 1);
data = This.data;

% Pad missing observations at the beginning of the first month
% and at the end of the last month with NaNs.
tmp = eomday(endYear,endMonth);
data = [nan([startDay-1,ncol]);data;nan([tmp-endDay,ncol])];

% Start-date and end-date of the calendar matrixt.
% startdate = datenum(startyear,startmonth,1);
% enddate = datenum(endyear,endmonth,tmp);

year = startYear : endYear;
nYear = length(year);
year = year(ones([1,12]),:);
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
x = [];
for t = 1 : nPer
    tmp = nan(ncol,31);
    tmp(:,1:lastDay(t)) = transpose(data(1:lastDay(t),:));
    x = [x;tmp]; %#ok<AGROW>
    data(1:lastDay(t),:) = [];
end

RowStart = datenum(year,month,1);

end
% xxcalendar().
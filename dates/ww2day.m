function Day = ww2day(Dat,WDay)
% ww2day  Convert weekly IRIS serial date number to Matlab serial date number.
%
% Syntax
% =======
%
%     Day = ww2day(Dat)
%     Day = ww2day(Dat,WDay)
%
% Input arguments
% ================
%
% * `Dat` [ numeric ] - IRIS serial number for weekly date.
%
% * `WDay` [ `'Mon'` | `'Tue'` | `'Wed'` | `'Thu'` | `'Fri'` | `'Sat'` |
% `'Sun'` ] - The day of the week that will represent the input week,
% `Dat`; if omitted, the week will be represented by its Thursday.
%
% Output arguments
% =================
%
% * `Day` [ numeric ] - Matlab serial date number representing Thursday in
% that week.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

try
    WDay; %#ok<VUNUS>
catch
    WDay = 'Thu';
end

days = {'Monday','Tuesday','Wednesday', ...
    'Thursday','Friday','Saturday','Sunday'};

%--------------------------------------------------------------------------

% First week in year 0 starts on Monday, January 3. IRIS serial number for
% this week (0W1) is 0.
start = 3;

p = find(strncmpi(WDay,days,3),1) - 1;
if isempty(p)
    p = 0;
end

% Matlab serial number for Monday, Thursday, or Sunday in the `Dat` week,
% depending on the position `Pos`.
Day = start + floor(Dat)*7 + p;

end
function Dat = day2ww(Day)
% day2ww  Convert Matlab serial date number into weekly IRIS serial date number.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

if ischar(Day) || iscellstr(Day)
    Day = datenum(Day);
end
Day = floor(Day);

% First week in year 0 starts on Monday, January 3. Matlab serial date
% number for this day is 3.
start = 3;

% IRIS serial number for the first week in year 0 (0W1) is 0.
Dat = floor((Day - start) / 7);

Dat = Dat + 0.52;

end
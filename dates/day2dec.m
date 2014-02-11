function Dec = day2dec(Day)
% day2dec  [Not a public function] Convert Matlab serial date numbers to
% decimal representation.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

Day = floor(Day);
[year,~,~] = datevec(Day);
yearStart = datenum(year,1,1);
nDay = daysinyear(year);
dayCount = Day - yearStart;
Dec = year + dayCount ./ nDay;

end
function F = fwymonday(Year)
% fwy  [Not a public function] Matlab serial date number for Monday in the
% first week of the year.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

% By ISO 8601:
% * Weeks start with Mondays;
% * First week of the year is the week that contains the 4th day of January.
fourthJan = datenum(Year,1,4);

% Day of the week: Monday=1, ..., Sunday=7. This is different from Matlab where Sunday=1.
fourthJanDow = weekdayiso(fourthJan);

% Serial number for MOnday in the first week.
F = fourthJan - fourthJanDow + 1; 

end
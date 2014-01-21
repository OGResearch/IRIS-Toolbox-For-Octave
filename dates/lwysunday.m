function L = lwysunday(Year)
% fwy  [Not a public function] Matlab serial date number for Sunday in the
% last week of the year.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

f = fwymonday(Year+1);
L = f - 1;

end
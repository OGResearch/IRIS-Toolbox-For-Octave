function W = weekdayiso(D)
% weekdayiso  [Not a public function] ISO 8601 day of the week number
% (Monday=1, etc.)
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

W = mod(fix(D)-3,7) + 1;

end
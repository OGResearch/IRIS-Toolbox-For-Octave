function p = month2per(m,f)
% month2per  [Not a public function] Convert month to lower-freq period.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%**************************************************************************

p = ceil(m.*f./12);

end
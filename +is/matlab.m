function Flag = matlab()
% matlab  [Not a public function] True if called from within Matlab.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

Flag = ~exist('OCTAVE_VERSION','builtin');

end
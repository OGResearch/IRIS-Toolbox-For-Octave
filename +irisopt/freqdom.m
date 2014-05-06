function default = freqdom()
% freqdom  [Not a public function] Default options for freqdom package functions.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%**************************************************************************

default = struct();

default.xsf2phase = { ...
    'unwrap',false,@(isArg)is.logicalscalar(isArg), ...
    };

end
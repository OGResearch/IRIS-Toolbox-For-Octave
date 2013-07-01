function Def = stlop()
% stlop  [Not a public function] Default options for stlop class functions.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

Def = struct();

Def.estimate = { ...
    'const,constant',true,@islogicalscalar, ...
    'horizon',1,@(x) isnumericscalar(x) && x >= 1 && x == round(x), ...
    'order',1,@(x) isnumericscalar(x) && x >= 1 && x == round(x), ...
    'transition',true,@islogicalscalar, ...
    };

Def.forecast = { ...
    };

end
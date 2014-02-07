function Def = modelobj()
% modelobj  [Not a public function] Default options for modelobj functions.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

Def = struct();

Def.autocaption = { ...
    'corr','Corr $shock1$ X $shock2$',@ischar, ...
    'std','Std $shock$',@ischar, ...
    };

end
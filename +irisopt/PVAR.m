function Def = PVAR()
% PVAR  [Not a public function] Default options for PVAR class functions.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.


%--------------------------------------------------------------------------

Def = struct();

VARDef = irisopt.VAR();

Def.estimate = { ...
    VARDef.estimate{:}, ...
    'groupweights,groupweight',[],@(x) isempty(x) || isnumeric(x), ...
    }; %#ok<CCAT>

end
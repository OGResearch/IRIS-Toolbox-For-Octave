function Def = varobj()
% varobj  [Not a public function] Default options for varobj class functions.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

Def = struct();

Def.varobj = { ...
    'baseyear',@config,@(x) isempty(x) || isequal(x,@config) || is.intscalar(x), ...
    'comment','',@ischar, ...
    'userdata',[],true, ...
    };

end
function Def = grouping()
% grouping  [Not a public function] Default options for grouping class.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

Def.eval = { ...
    'append',true,@(varargin)is.logicalscalar(varargin{:}), ...
    };

end
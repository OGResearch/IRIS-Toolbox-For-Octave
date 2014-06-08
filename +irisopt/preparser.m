function Def = preparser()
% preparser  [Not a public function] Default options for preparser class functions.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

Def = struct();

Def.preparser = { ...
   'assign',struct(),@(x) isempty(x) || isstruct(x), ...
   'clone','',@(x) isempty(x) || preparser.mychkclonestring(x), ...
   'removecomments,removecomment',{},@iscell, ...
   'saveas','',@ischar, ...
};

end
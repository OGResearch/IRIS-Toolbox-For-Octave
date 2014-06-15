function default = strfun()
% strfun  [Not a public function] Default options for strfun package.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%**************************************************************************

default = struct();

default.cslist = {
   'lead','',@ischar, ...
   'quote','none',@(x) any(strcmpi(x,{'none','single','double'})), ...
   'spaced',true,@(isArg)is.logicalscalar(isArg), ...
   'trail','',@ischar, ...
   'wrap',Inf,@(isArg)is.numericscalar(isArg), ...
};

end
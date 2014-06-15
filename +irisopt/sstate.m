function default = sstate()
% sstate  [Not a public function] Default options for steady-state functions.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%**************************************************************************

default = struct();

default.sstate = { ...
   'assign',struct(),@(x) isempty(x) || isstruct(x), ...
   'saveas','',@ischar, ...
};

default.compile = { ...
   'excludezero',false,@(isArg)is.logicalscalar(isArg), ...
   'deletesymbolicmfiles,deletesymbolicmfile',true,@(isArg)is.logicalscalar(isArg), ...
   'end',Inf,@(x) is.numericscalar(x) || ischar(x), ...
   'simplify',Inf,@(isArg)is.numericscalar(isArg), ...
   'start',1,@(x) is.numericscalar(x) || ischar(x), ...
   'symbolic',true,@(isArg)is.logicalscalar(isArg), ...
   ... Optim Tbx settings
   'tolx',1e-12,@(isArg)is.numericscalar(isArg), ...
   'tolfun',1e-12,@(isArg)is.numericscalar(isArg), ...
   'maxiter',500,@(isArg)is.numericscalar(isArg), ...
   'maxfunevals',10000,@(isArg)is.numericscalar(isArg), ...
   'display','notify',@(x) ischar(x) ...
      && any(strcmpi(x,{'notify','iter','off','final','none'})), ...
};

end
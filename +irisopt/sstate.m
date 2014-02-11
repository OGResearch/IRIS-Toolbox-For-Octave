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
   'excludezero',false,@is.logicalscalar, ...
   'deletesymbolicmfiles,deletesymbolicmfile',true,@is.logicalscalar, ...
   'end',Inf,@(x) is.numericscalar(x) || ischar(x), ...
   'simplify',Inf,@is.numericscalar, ...
   'start',1,@(x) is.numericscalar(x) || ischar(x), ...
   'symbolic',true,@is.logicalscalar, ...
   ... Optim Tbx settings
   'tolx',1e-12,@is.numericscalar, ...
   'tolfun',1e-12,@is.numericscalar, ...
   'maxiter',500,@is.numericscalar, ...
   'maxfunevals',10000,@is.numericscalar, ...
   'display','notify',@(x) ischar(x) ...
      && any(strcmpi(x,{'notify','iter','off','final','none'})), ...
};

end
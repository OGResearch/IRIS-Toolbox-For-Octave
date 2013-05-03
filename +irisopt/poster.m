function def = poster()
% poster  [Not a public function] Default options for poster class.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%**************************************************************************

def = struct();

def.arwm = { ...
    'burnin',0.10,@(x) isnumericscalar(x) ...
    && ((x >= 0 && x < 1) || (x > 1 && x == round(x))), ...
    'esttime',false,@islogicalscalar, ...
    'initscale',1/3,@isnumericscalar, ...
    'gamma',0.8,@(x) isnumericscalar(x) ....
    && ( (x > 0.5 && x <= 1) || isnan(x) || isinf(x) ), ...
    'adaptscale',1,@(x) isnumericscalar(x) && x >= 0, ...
    'adaptproposalcov',0.5,@(x) isnumericscalar(x) && x >= 0, ...
    'progress',false,@islogicalscalar, ...
    'saveevery',Inf,@(x) isintscalar(x) && x > 0, ...
    'saveas','',@ischar, ...
    'targetar',0.234,@(x) isnumericscalar(x) && x > 0 && x <= 0.5, ...
    };

def.impsamp = { ...
    'progress',false,@islogicalscalar, ...
    };

def.stats = { ...
    'esttime',false,@islogicalscalar, ...
    'hpdicover',90,@(x) isnumericscalar(x) && x >= 0 && x <= 100, ...
    'histbins,histbin',50,@(x) isnintscalar(x) && x > 0, ...
    'mddgrid',0.1:0.1:0.9,@(x) isnumeric(x) && all(x(:) > 0 & x(:) < 1), ...
    'output','',@(x) ischar(x) || iscellstr(x), ...
    'progress',false,@islogicalscalar, ...
    ...
    'chain',true,@islogicalscalar, ...
    'cov',false,@islogicalscalar, ...
    'mean',true,@islogicalscalar, ...
    'median',false,@islogicalscalar, ...
    'mode',false,@islogicalscalar, ...
    'mdd,lmdd',true,@islogicalscalar, ...
    'std',true,@islogicalscalar, ...
    'hpdi',false,@(x) islogicalscalar(x) || (isnumericscalar(x) && x > 0 && x < 100), ...
    'hist',true,@(x) islogicalscalar(x) || (isintscalar(x) && x > 0), ...
    'bounds',false,@islogicalscalar, ...
    'ksdensity',false,@(x) islogicalscalar(x) || isempty(x) || (isintscalar(x) && x > 0), ...
    'prctile,pctile',[],@(x) isnumeric(x) && all(x(:) >= 0 & x(:) <= 100), ...
    };

def.testpar = { ...
    };

end
function Def = VAR()
% VAR  [Not a public function] Default options for VAR class functions.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

Def = struct();

outputFmt = { ...
    'output','auto',@(x) any(strcmpi(x,{'auto','dbase','tseries','array'})), ...
    };

applyFilter = { ...
    'applyto',Inf,@(x) isnumeric(x) || islogical(x) || isequal(x,':') || iscellstr(x), ...
    'filter','',@ischar, ...
    };

tolerance = { ...
    'tolerance',getrealsmall(),@isnumericscalar, ...
    };

output = { ...
    'output','namedmat',@(x) ischar(x) && any(strcmpi(x,{'namedmat','numeric'})), ...
    };

Def.acf = { ...
    applyFilter{:}, ...
    output{:}, ...
    'nfreq',256,@isnumericscalar, ...
    'order',0,@isnumericscalar, ...
    'progress',false,@islogicalscalar, ...
    }; %#ok<*CCAT>

Def.demean = { ...
   };

Def.estimate = [ ...
    outputFmt, { ...
    'a',[],@isnumeric, ...
    'bvar',[],@(x) isempty(x) || isa(x,'BVAR.bvarobj'), ...
    'c',[],@isnumeric, ...
    'diff',false,@islogicalscalar, ...
    'g',[],@isnumeric, ...
    'order',1,@(x) isnumeric(x) && numel(1) == 1, ...
    'cointeg',[],@isnumeric, ...
    'comment','',@(x) ischar(x) || isequal(x,Inf), ...
    'constraints,constraint','',@(x) ischar(x) || isnumeric(x), ...
    'constant,const,constants',true,@islogicalscalar, ...
    'covparameters,covparameter',false,@islogicalscalar, ...
    'eqtnbyeqtn',false,@islogicalscalar, ...
    'maxiter',1,@isnumericscalar, ...
    'mean',[],@(x) isempty(x) || isnumeric(x), ...
    'progress',false,@islogicalscalar, ...
    'schur',true,@islogicalscalar, ...
    'stdize',false,@islogicalscalar, ...
    'tolerance',1e-5,@isnumericscalar, ...
    'timeweights',[],@(x) isempty(x) || isa(x,'tseries'), ...
    'ynames,yname',{},@iscellstr, ...
    'enames,ename',{},@iscellstr, ...
    'warning',true,@islogicalscalar, ...
    ...
    'fixedeffect',false,@islogicalscalar, ...
    'groupweights',[],@(x) isempty(x) || isnumeric(x), ...
    }];

Def.filter = { ...
    'ahead',1,@(x) isnumeric(x) || x == round(x) || x >= 1, ...
    'cross',true,@(x) islogicalscalar(x) || (isnumericscalar(x) && x >=0 && x <= 1), ...
    'deviation,deviations',false,@islogicalscalar, ...
    'meanonly',false,@islogicalscalar, ...
    'omega',[],@isnumeric, ...
    'output','smooth',@ischar, ...    
    };

Def.fmse = { ...
    output{:}, ...
    }; %#ok<CCAT1>

Def.forecast = { ...
    outputFmt{:},  ...
    'cross',true,@(x) islogicalscalar(x) || (isnumericscalar(x) && x >=0 && x <= 1), ...
    'dboverlay,dbextend',false,@islogicalscalar, ...
    'deviation,deviations',false,@islogicalscalar, ...
    'meanonly',false,@islogicalscalar, ...
    'omega',[],@isnumeric, ...
    'returninstruments,returninstrument',true,@islogicalscalar, ...
    'returnresiduals,returnresidual',true,@islogicalscalar, ...
    };

Def.integrate = { ...
    'applyto',Inf,@(x) isnumeric(x) || islogical(x), ...
    };

Def.isexplosive = [ ...
    tolerance, ...
    ];

Def.isstationary = [ ...
    tolerance, ...
    ];


Def.portest = { ...
    'level',0.05,@(x) isnumericscalar(x) && x > 0 && x < 1, ...
    };

Def.resample = { ...
    outputFmt{:}, ...
    'deviation,deviations',false,@islogicalscalar, ...   
    'method','montecarlo',@(x) isfunc(x) ...
    || (ischar(x) && any(strcmpi(x,{'montecarlo','bootstrap'}))), ...
    'progress',false,@islogicalscalar, ...
    'randomise,randomize',false,@islogicalscalar, ...
    'wild',false,@islogicalscalar, ...
    };

Def.simulate = { ...
    outputFmt{:}, ...
    'contributions,contribution',false,@islogicalscalar, ...
    'deviation,deviations',false,@islogicalscalar, ...
    'returnresiduals,returnresidual',true,@islogicalscalar, ...
    };

Def.sprintf = { ...
    'constant,constants,const',true,@islogicalscalar, ...
    'decimal',[], @(x) isempty(x) || isnumericscalar(x), ...
    'declare',false,@islogicalscalar, ...
    'enames,ename',[],@(x) isempty(x) || iscellstr(x) || isfunc(x), ...
    'format','%+.16g',@ischar, ...
    'hardparameters,hardparameter',true,@islogicalscalar, ...
    'tolerance',getrealsmall(),@isnumericscalar, ...
    'ynames,yname',[],@(x) isempty(x) || iscellstr(x), ...
    };

Def.response = { ...
    'presample',false,@islogicalscalar, ...
    'select',Inf,@(x) isequal(x,Inf) || islogical(x) || isnumeric(x) || ischar(x) || iscellstr(x), ...
    };

Def.VAR = { ...
    'userdata',[],true, ...
    };

Def.xsf = { ...
    applyFilter{:}, ...
    'progress',false,@islogicalscalar, ...
    };

end
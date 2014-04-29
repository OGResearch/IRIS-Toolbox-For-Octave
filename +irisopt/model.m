function Def = model()
% model  [Not a public function] Default options for model class functions.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

solveValid = @(x) is.logicalscalar(x) ...
    || (iscell(x) && iscellstr(x(1:2:end)));

deviation_dtrends = { ...
    'deviation,deviations',false,@(isArg)is.logicalscalar(isArg), ...
    'dtrends,dtrend','auto',@(x) is.logicalscalar(x) || isequal(x,'auto'), ...
    };

precision = { ...
    'precision','double',@(x) is.anychari(x,{'double','single'}), ...
    };

applyfilter = {
    'applyto',Inf,@(x) isequal(x,':') || isequal(x,Inf) || iscellstr(x), ...
    'filter','',@ischar, ...
    };

swap = { ...
    'endogenise,endogenize',{},@(x) isempty(x) || iscellstr(x) || ischar(x), ...
    'exogenise,exogenize',{},@(x) isempty(x) || iscellstr(x) || ischar(x), ...
    };

output = { ...
    'output','namedmat',@(x) ischar(x) && any(strcmpi(x,{'namedmat','numeric'})), ...
    };

sstate = { ...
    'sstate,sstateopt',false,@(x) islogical(x) ...
    || (iscell(x) && iscellstr(x(1:2:end))) ...
    || isa(x,'function_handle') ...
    || (iscell(x) && ~isempty(x) && isa(x{1},'function_handle')), ...
    };

mysstate = { ...
    'blocks,block',false,@(isArg)is.logicalscalar(isArg), ...
    swap{:}, ...
    'fix',{},@(x) isempty(x) || iscellstr(x) || ischar(x), ...
    'fixallbut',{},@(x) isempty(x) || iscellstr(x) || ischar(x), ...
    'fixlevel',{},@(x) isempty(x) || iscellstr(x) || ischar(x), ...
    'fixlevelallbut',{},@(x) isempty(x) || iscellstr(x) || ischar(x), ...
    'fixgrowth',{},@(x) isempty(x) || iscellstr(x) || ischar(x), ...
    'fixgrowthallbut',{},@(x) isempty(x) || iscellstr(x) || ischar(x), ...
    'growth',false,@(isArg)is.logicalscalar(isArg), ...
    'linear','auto',@(x) is.logicalscalar(x) ...
    || (ischar(x) && strcmpi(x,'auto')), ...
    'maxiter',1000,@(x) isnumeric(x) && length(x) == 1 && round(abs(x)) == x, ...
    'maxfunevals',1000,@(x) isnumeric(x) && length(x) == 1 && round(abs(x)) == x, ...
    'optimset',{},@(x) isempty(x) || (iscell(x) && iscellstr(x(1:2:end))), ...
    'naninit,init',1,@(x) is.numericscalar(x) && isfinite(x), ...
    'refresh',true,@(isArg)is.logicalscalar(isArg), ...
    'resetinit',[],@(x) isempty(x) || (is.numericscalar(x) && isfinite(x)), ...
    'reuse',false,@(isArg)is.logicalscalar(isArg), ...
    'solver','lsqnonlin',@(x) ischar(x) || is.func(x), ...
    'tolx',1e-12,@(x) isnumeric(x) && length(x) == 1 && x > 0, ...
    'tolfun',1e-12,@(x) isnumeric(x) && length(x) == 1 && x > 0, ...
    'zeromultipliers',false,@(isArg)is.logicalscalar(isArg), ...
    };


Def = struct();

Def.acf = {
    'acf',{},@(x) iscell(x) && iscellstr(x(1:2:end)), ...
    applyfilter{:}, ...
    'nfreq',256,@(isArg)is.numericscalar(isArg), ...
    'contributions,contribution',false,@(isArg)is.logicalscalar(isArg), ...
    'order',0,@(isArg)is.numericscalar(isArg), ...
    output{:}, ...
    'select',Inf,@(x) (isnumeric(x) && all(isinf(x))) || iscellstr(x) || ischar(x), ...
    }; %#ok<*CCAT>

Def.bn = { ...
    deviation_dtrends{:}, ...
    }; %#ok<CCAT1>

Def.chksstate = { ...
    'error',true,@(isArg)is.logicalscalar(isArg), ...
    'refresh',true,@(isArg)is.logicalscalar(isArg), ...
    'warning',true,@(isArg)is.logicalscalar(isArg), ...
    };

Def.mychksstate = { ...
    'sstateeqtn',false,@(isArg)is.logicalscalar(isArg), ...
    'tolerance',getrealsmall(),@(isArg)is.numericscalar(isArg), ...
    };

Def.diffloglik = {...
    'chksstate',true,@(x) is.logicalscalar(x) ...
    || (iscell(x) && iscellstr(x(1:2:end))), ...
    'progress',false,@(isArg)is.logicalscalar(isArg), ...
    'refresh',true,@(isArg)is.logicalscalar(isArg), ...
    'solve',true,solveValid, ...
    sstate{:}, ...
    };

% Combine model/estimate with estimateobj/myestimate.
estimateobj = irisopt.estimateobj();
Def.estimate = [ ...
    estimateobj.myestimate, { ...
    'chksstate',true,@(x) is.logicalscalar(x) ...
    || (iscell(x) && iscellstr(x(1:2:end))), ...
    'domain','time',@(x) any(strncmpi(x,{'t','f'},1)), ...
    'filter,filteropt',{},@(x) isempty(x) ...
    || (iscell(x) && iscellstr(x(1:2:end))), ...
    'nosolution','error',@(x) any(strcmpi(x,{'error','penalty'})), ...
    'refresh',true,@(isArg)is.logicalscalar(isArg), ...
    'solve',true,solveValid, ...
    sstate{:}, ...
    'zero',false,@(isArg)is.logicalscalar(isArg), ...
    }];

Def.fevd = {
    'select',Inf,@(x) isequal(x,Inf) || ischar(x) || iscellstr(x), ...
    output{:}, ...
    };

Def.fmse = {
    'select',Inf,@(x) isequal(x,Inf) || ischar(x) || iscellstr(x), ...
    output{:}, ...
    };

Def.ffrf = {
    'include',Inf,@(x) isempty(x) || isequal(x,Inf) || ischar(x) || iscellstr(x), ...
    'exclude',{},@(x) isempty(x) || ischar(x) || iscellstr(x), ...
    'maxiter',[],@(x) isempty(x) || (is.numericscalar(x) && x >= 0), ...
    output{:}, ...
    'select',Inf,@(x) isequal(x,Inf) || ischar(x) || iscellstr(x), ...
    'tolerance',[],@(x) isempty(x) || (is.numericscalar(x) && x > 0), ...
    };

Def.filter = { ...
    'data,output','smooth',@(x) ischar(x), ...
    'refresh',true,@(isArg)is.logicalscalar(isArg), ...
    };

Def.fisher = { ...
    'chksgf',false,@(isArg)is.logicalscalar(isArg), ...
    'chksstate',true,@(x) is.logicalscalar(x) ...
    || (iscell(x) && iscellstr(x(1:2:end))), ...
    'deviation',true,@(isArg)is.logicalscalar(isArg), ...
    'epspower',1/3,@(isArg)is.numericscalar(isArg), ...
    'exclude',{},@(x) ischar(x) || iscellstr(x), ...
    'percent',false,@(isArg)is.logicalscalar(isArg), ...
    'progress',false,@(isArg)is.logicalscalar(isArg), ...
    'refresh',true,@(isArg)is.logicalscalar(isArg), ...
    'solve',true,solveValid,...
    sstate{:}, ...
    'tolerance',eps()^(2/3),@(isArg)is.numericscalar(isArg), ...
    };

Def.forecast = {...
    'anticipate',true,@(isArg)is.logicalscalar(isArg), ...
    deviation_dtrends{:}, ...
    'initcond','data',@(x) any(strcmpi(x,{'data','fixed'})) || isnumeric(x), ...
    'meanonly',false,@(isArg)is.logicalscalar(isArg), ...
    'std',[],@(x) isstruct(x) || isempty(x), ...
    'tolmse',getrealsmall('mse'),@(x) isnumeric(x) && length(x) == 1, ...
    };

Def.jforecast = {...
    'anticipate',true,@(isArg)is.logicalscalar(isArg), ...
    'currentonly',true,@(isArg)is.logicalscalar(isArg), ...
    deviation_dtrends{:}, ...
    'initcond','data',@(x) any(strcmpi(x,{'data','fixed'})) || isnumeric(x), ...
    'meanonly',false,@(isArg)is.logicalscalar(isArg), ...
    'precision','double',@(x) ischar(x) && any(strcmpi(x,{'double','single'})), ...
    'progress',false,@(isArg)is.logicalscalar(isArg), ...
    'plan',[],@(x) isa(x,'plan') || isempty(x), ...
    'vary,std',[],@(x) isstruct(x) || isempty(x), ...
    };

Def.icrf = {...
    'delog',true,@(isArg)is.logicalscalar(isArg),...
    'log',[],@(x) isempty(x) || is.logicalscalar(x), ...
    'size',[],@(x) isempty(x) || is.numericscalar(x), ...
    };

Def.ifrf = {...
    output{:}, ...
    'select',Inf,@(x) isequal(x,Inf) || ischar(x) || iscellstr(x), ...
    };

Def.loglik = { ...
    'domain','time',@(x) any(strncmpi(x,{'t','f'},1)), ...
    'persist',false,@(isArg)is.logicalscalar(isArg), ...
    };

Def.fdlik = { ...
    'band',[2,Inf],@(x) isnumeric(x) && length(x) == 2, ...
    deviation_dtrends{:}, ...
    'exclude',[],@(x) isempty(x) || ischar(x) || iscellstr(x) || islogical(x), ...
    'objdecomp',false,@is.logicalscalar, ...
    'outoflik',{},@(x) ischar(x) || iscellstr(x), ...
    'relative',true,@(isArg)is.logicalscalar(isArg), ...
    'zero',true,@(isArg)is.logicalscalar(isArg), ...
    };

Def.lognormal = { ...
    'fresh',false,@(isArg)is.logicalscalar(isArg), ...
    'mean',true,@(isArg)is.logicalscalar(isArg), ...
    'median',true,@(isArg)is.logicalscalar(isArg), ...
    'mode',true,@(isArg)is.logicalscalar(isArg), ...
    'prctile,pctile,pct',[5,95],@(x) isnumeric(x) && all(round(x(:)) > 0 & round(x(:)) < 100), ...
    'prefix','lognormal',@(x) ischar(x) && ~isempty(x), ...
    'std',true,@(isArg)is.logicalscalar(isArg), ...
    };

Def.kalman = { ...
    'ahead',1,@(x) is.numericscalar(x) && x > 0 && x == round(x), ...    
    'chkexact',false,@(isArg)is.logicalscalar(isArg), ...
    'chkfmse',false,@(isArg)is.logicalscalar(isArg), ...
    deviation_dtrends{:}, ...
    'condition',[],@(x) isempty(x) || ischar(x) || iscellstr(x) || islogical(x), ...
    'fmsecondtol',eps(),@(x) is.numericscalar(x) && x > 0 && x < 1, ...
    'returncont,contributions',false,@(isArg)is.logicalscalar(isArg), ...
    'initcond,init','stochastic',@(x) ...
    isstruct(x) ...
    || (ischar(x) && any(strcmpi(x,{'stochastic','fixed','optimal'}))), ...
    'initmeanunit','optimal',@(x) ...
    isstruct(x) || (ischar(x) && any(strcmpi(x,{'optimal'}))), ...
    'lastsmooth',Inf,@(x) isempty(x) || is.numericscalar(x), ...
    'nonlinear,nonlinearise,nonlinearize',0, ...
    @(x) is.numericscalar(x) && x == round(x) && x >= 0, ...
    'outoflik',{},@(x) ischar(x) || iscellstr(x), ...
    'objdecomp',false,@(isArg)is.logicalscalar(isArg), ...
    'objfunc,objective','loglik',@(x) any(strcmpi(x,{'loglik','mloglik','-loglik','prederr'})), ...
    'objrange,objectivesample',Inf,@isnumeric, ...
    'pedindonly',false,@(isArg)is.logicalscalar(isArg), ...
    precision{:}, ...
    'plan',[],@(x) isa(x,'plan') || isempty(x), ...
    'progress',false,@(isArg)is.logicalscalar(isArg), ...
    'relative',true,@(isArg)is.logicalscalar(isArg), ...
    'vary,std',[],@(x) isempty(x) || isstruct(x), ...
    'simulate',{},@(x) iscell(x) && iscellstr(x(1:2:end)), ...
    'symmetric',true,@(isArg)is.logicalscalar(isArg), ...
    'tolerance',eps()^(2/3),@isnumeric, ...
    'tolmse',0,@(x) (ischar(x) && strcmpi(x,'auto')) || is.numericscalar(x), ...
    'weighting',[],@isnumeric, ...
    'meanonly',false,@(isArg)is.logicalscalar(isArg), ...
    'returnstd',true,@(isArg)is.logicalscalar(isArg), ...
    'returnmse',true,@(isArg)is.logicalscalar(isArg), ...
    };

Def.model = {
    'addlead',false,@(isArg)is.logicalscalar(isArg), ...
    'declareparameters',true,@(isArg)is.logicalscalar(isArg), ...
    'multiple,allowmultiple',false,@(isArg)is.logicalscalar(isArg), ...
    'assign',[],@(x) isempty(x) || isstruct(x), ...
    'chksyntax',true,@(isArg)is.logicalscalar(isArg), ...
    'comment','',@ischar, ...
    'optimal','discretion', ...
    @(x) any(strcmpi(x,{'consistent','commitment','discretion'})), ...
    'epsilon',[],@(x) isempty(x) || (is.numericscalar(x) && x > 0 && x < 1), ...
    'removeleads,removelead',false,@(isArg)is.logicalscalar(isArg), ...
    'linear',false,@(isArg)is.logicalscalar(isArg), ...
    'multipliername','Mu_Eq%g',@(x) ischar(x) && ~isempty(strfind(x,'%g')), ...
    'precision','double',@(x) any(strcmp(x,{'double','single'})), ...
    'quadratic',false,@(isArg)is.logicalscalar(isArg), ...
    'saveas','',@ischar, ...
    'sstateonly',false,@(isArg)is.logicalscalar(isArg), ...
    'symbdiff,symbolicdiff',true,@(isArg)is.logicalscalar(isArg), ...
    'std',NaN,@(isArg)is.numericscalar(isArg), ...
    'tolerance',[],@(x) isempty(x) || (is.numericscalar(x) && x >= 0), ...
    'torigin',[],@(x) isempty(x) || is.intscalar(x), ...
    };

Def.neighbourhood = { ...
    'plot',true,@(isArg)is.logicalscalar(isArg), ...
    'progress',false,@(isArg)is.logicalscalar(isArg), ...
    'neighbourhood',[],@(x) isempty(x) || isstruct(x), ...
    };

Def.tcorule = { ...
    'beta',1,@(isArg)is.numericscalar(isArg), ...
    'display',5000,@(isArg)is.numericscalar(isArg), ...
    'ginverse',false,@(isArg)is.logicalscalar(isArg), ...
    'initexp',@eye,@(x) isnumeric(x) || is.func(x), ...
    'maxiter',50000,@(isArg)is.numericscalar(isArg), ...
    'reset',false,@(isArg)is.logicalscalar(isArg), ...
    'tolexp',1e-10,@(isArg)is.numericscalar(isArg), ...
    'tolrule',1e-10,@(isArg)is.numericscalar(isArg), ...
    'tolvalue',1e-6,@(isArg)is.numericscalar(isArg), ...
    'warning',true,@(isArg)is.logicalscalar(isArg), ...
    };

Def.regress = { ...
    'acf',{},@(x) iscell(x) && iscellstr(x(1:2:end)), ...
    output{:}, ...
    };
    
Def.resample = { ...
    deviation_dtrends{:}, ...
    'method','montecarlo',@(x) is.func(x) ...
    || (ischar(x) && any(strcmpi(x,{'montecarlo','bootstrap'}))), ...
    'progress',false,@(isArg)is.logicalscalar(isArg), ...
    'randominitcond,randomiseinitcond,randomizeinitcond,randomise,randomize',true,@(x) is.logicalscalar(x) || (is.numericscalar(x) && x >= 0), ...
    'svdonly',false,@(isArg)is.logicalscalar(isArg), ...
    'statevector','alpha',@(x) ischar(x) && any(strcmpi(x,{'alpha','x'})), ...
    'vary',[],@(x) isempty(x) || isstruct(x), ...
    'wild',false,@(isArg)is.logicalscalar(isArg), ...
    };

Def.shockplot = { ...
    'dbplot',{},@(x) iscell(x) && iscellstr(x(1:2:end)), ...
    'deviation',true,@(isArg)is.logicalscalar(isArg), ...
    'dtrends,dtrend','auto',@(x) is.logicalscalar(x) || isequal(x,'auto'), ...
    'simulate',{},@(x) iscell(x) && iscellstr(x(1:2:end)), ...
    'shocksize,size','std',@(x) (ischar(x) && strcmpi(x,'std')) || isnumeric(x), ...
    };

Def.simulate = { ...
    'anticipate',true,@(isArg)is.logicalscalar(isArg), ...
    'contributions,contribution',false,@(isArg)is.logicalscalar(isArg), ...
    'dboverlay,dbextend',false,@(x) is.logicalscalar(x) || isstruct(x), ...
    deviation_dtrends{:}, ...
    'fast',true,@(isArg)is.logicalscalar(isArg), ...
    'ignoreshocks,ignoreshock,ignoreresiduals,ignoreresidual', ...
    false,@(isArg)is.logicalscalar(isArg), ...
    'plan',[],@(x) isa(x,'plan') || isempty(x), ...
    'progress',false,@(isArg)is.logicalscalar(isArg), ...
    'missing',NaN,@isnumeric, ...
    ... Options for non-linear simulations
    'nonlinearise,nonlinearize,nonlinear', ...
    0,@(x) isempty(x) || isnumeric(x), ...
    'addsstate',true,@(isArg)is.logicalscalar(isArg), ...
    'display', ...
    100,@(x) is.logicalscalar(x) || (is.numericscalar(x) && x >= 0 && x == round(x)), ...
    'error',false,@(isArg)is.logicalscalar(isArg), ...
    'fillout',false,@(isArg)is.logicalscalar(isArg), ...
    'lambda',1,@(x) is.numericscalar(x) && all(x > 0 & x <= 1), ...
    'reducelambda,lambdafactor', ...
    0.5,@(x) is.numericscalar(x) && x > 0 && x <= 1, ...
    'maxiter',100,@(isArg)is.numericscalar(isArg), ...
    'tolerance',1e-5,@(isArg)is.numericscalar(isArg), ...
    'upperbound',1.5,@(x) is.numericscalar(x) && all(x > 1), ...
    };

Def.solve = { ...
    'expand,forward',0,@(x) isnumeric(x) && length(x) == 1, ...
    'fast',false,@(isArg)is.logicalscalar(isArg), ...
    'linear','auto',@(x) is.logicalscalar(x) ...
    || (ischar(x) && strcmpi(x,'auto')), ...
    'error',false,@(isArg)is.logicalscalar(isArg), ...
    'progress',false,@(isArg)is.logicalscalar(isArg), ...
    'refresh',true,@(isArg)is.logicalscalar(isArg), ...
    'select',true,@(isArg)is.logicalscalar(isArg), ...
    'eqtn,equations','all',@(x) ischar(x) ...
    && any(strcmpi(x,{'all','measurement','transition'})), ...
    'symbolic',true,@(isArg)is.logicalscalar(isArg), ...
    'warning',true,@(isArg)is.logicalscalar(isArg), ...
    };

Def.sourcedb = { ...
    'ndraw',1,@(x) is.numericscalar(x) && x >= 0 && x == round(x), ...
    'ncol',1,@(x) is.numericscalar(x) && x >= 0 && x == round(x), ...
    deviation_dtrends{:}, ...
    'randomshocks,randomshock',false,@(isArg)is.logicalscalar(isArg), ...
    'residuals,residual',[],@(x) isempty(x) || is.func(x), ...
    };

Def.srf = {...
    'log',[],@(x) isempty(x) || is.logicalscalar(x), ...
    'delog',true,@(isArg)is.logicalscalar(isArg), ...
    'select',Inf,@(x) (isnumeric(x) && length(x) == 1 && isinf(x)) || iscellstr(x) || ischar(x), ...
    'size','std',@(x) (ischar(x) && strcmpi(x,'std')) || is.numericscalar(x), ...
    };

Def.sspace = { ...
    'triangular',true,@(isArg)is.logicalscalar(isArg), ...
    'removeinactive',false,@(isArg)is.logicalscalar(isArg), ...
    };

Def.sstate = { ...
    'linear','auto',@(x) isequal(x,'auto') ...
    || isequal(x,true) || isequal(x,false), ...
    'solve',false,solveValid, ...
    };

Def.mysstateverbose = { ...
    mysstate{:}, ...
    'display','iter',@(x) isempty(x) || islogical(x) || is.anychari(x,{'iter','final','off','notify','none'}), ...
    'warning',true,@(isArg)is.logicalscalar(isArg), ...
    };

Def.mysstatesilent = { ...
    mysstate{:}, ...
    'display','off',@(x) isempty(x) || islogical(x) || is.anychari(x,{'iter','final','off','notify','none'}), ...
    'warning',false,@(isArg)is.logicalscalar(isArg), ...
    };

Def.sstatefile = { ...
    swap{:}, ...
    'growthnames,growthname','d?',@ischar, ...
    'time',true,@(isArg)is.logicalscalar(isArg), ...
    };

Def.system = { ...
    'eqtn,equations','all',@(x) ischar(x) ...
    'linear','auto',@(x) is.logicalscalar(x) ...
    || (ischar(x) && strcmpi(x,'auto')), ...
    'select',true,@(isArg)is.logicalscalar(isArg), ...
    'sparse',false,@(isArg)is.logicalscalar(isArg), ...
    'symbolic',true,@(isArg)is.logicalscalar(isArg), ...
    };

Def.VAR = { ...
    'acf',{},@(x) iscell(x) && iscellstr(x(1:2:end)), ...
    'order',1,@(isArg)is.numericscalar(isArg), ...
    'constant,const',true,@(isArg)is.logicalscalar(isArg), ...
    };

Def.vma = {
    'select',Inf,@(x) isequal(x,Inf) || ischar(x) || iscellstr(x), ...
    output{:}, ...
    };

Def.xsf = {
    applyfilter{:}, ...
    output{:}, ...
    'progress',false,@(isArg)is.logicalscalar(isArg), ...
    'select',Inf,@(x) isequal(x,Inf) || ischar(x) || iscellstr(x), ...
    };

end
function Def = model()
% model  [Not a public function] Default options for model class functions.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

deviation_dtrends = { ...
    'deviation,deviations',false,@islogicalscalar, ...
    'dtrends,dtrend','auto',@(x) islogicalscalar(x) || isequal(x,'auto'), ...
    };

precision = { ...
    'precision','double',@(x) isanychari(x,{'double','single'}), ...
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

mysstate = { ...
    'blocks,block',false,@islogicalscalar, ...
    swap{:}, ...
    'fix',{},@(x) isempty(x) || iscellstr(x) || ischar(x), ...
    'fixallbut',{},@(x) isempty(x) || iscellstr(x) || ischar(x), ...
    'fixlevel',{},@(x) isempty(x) || iscellstr(x) || ischar(x), ...
    'fixlevelallbut',{},@(x) isempty(x) || iscellstr(x) || ischar(x), ...
    'fixgrowth',{},@(x) isempty(x) || iscellstr(x) || ischar(x), ...
    'fixgrowthallbut',{},@(x) isempty(x) || iscellstr(x) || ischar(x), ...
    'growth',false,@islogicalscalar, ...
    'linear','auto',@(x) islogicalscalar(x) ...
    || (ischar(x) && strcmpi(x,'auto')), ...
    'maxiter',1000,@(x) isnumeric(x) && length(x) == 1 && round(abs(x)) == x, ...
    'maxfunevals',1000,@(x) isnumeric(x) && length(x) == 1 && round(abs(x)) == x, ...
    'optimset',{},@(x) isempty(x) || (iscell(x) && iscellstr(x(1:2:end))), ...
    'naninit,init',1,@(x) isnumericscalar(x) && isfinite(x), ...
    'refresh',true,@islogicalscalar, ...
    'resetinit',[],@(x) isempty(x) || (isnumericscalar(x) && isfinite(x)), ...
    'reuse',false,@islogicalscalar, ...
    'solve',false,@islogicalscalar, ...
    'solver','lsqnonlin',@(x) ischar(x) || isfunc(x), ...
    'tolx',1e-12,@(x) isnumeric(x) && length(x) == 1 && x > 0, ...
    'tolfun',1e-12,@(x) isnumeric(x) && length(x) == 1 && x > 0, ...
    'zeromultipliers',false,@islogicalscalar, ...
    };

Def = struct();

Def.acf = {
    'acf',{},@(x) iscell(x) && iscellstr(x(1:2:end)), ...
    applyfilter{:}, ...
    'nfreq',256,@isnumericscalar, ...
    'contributions,contribution',false,@islogicalscalar, ...
    'order',0,@isnumericscalar, ...
    output{:}, ...
    'select',Inf,@(x) (isnumeric(x) && all(isinf(x))) || iscellstr(x) || ischar(x), ...
    }; %#ok<*CCAT>

Def.bn = { ...
    deviation_dtrends{:}, ...
    }; %#ok<CCAT1>

Def.chksstate = { ...
    'error',true,@islogicalscalar, ...
    'refresh',true,@islogicalscalar, ...
    'warning',true,@islogicalscalar, ...
    };

Def.mychksstate = { ...
    'sstateeqtn',false,@islogicalscalar, ...
    'tolerance',getrealsmall(),@isnumericscalar, ...
    };

Def.diffloglik = {...
    'chksstate',true,@(x) islogicalscalar(x) ...
    || (iscell(x) && iscellstr(x(1:2:end))), ...
    'progress',false,@islogicalscalar, ...
    'refresh',true,@islogicalscalar, ...
    'solve',true,@islogicalscalar, ...
    'sstate',false,@(x) islogical(x) || (iscell(x) && iscellstr(x(1:2:end))), ...
    };

Def.estimate = { ...
    'chksstate',true,@(x) islogicalscalar(x) ...
    || (iscell(x) && iscellstr(x(1:2:end))), ...
    'domain','time',@(x) any(strncmpi(x,{'t','f'},1)), ...
    'filter,filteropt',{},@(x) isempty(x) ...
    || (iscell(x) && iscellstr(x(1:2:end))), ...
    'nosolution','error',@(x) any(strcmpi(x,{'error','penalty'})), ...
    'refresh',true,@islogicalscalar, ...
    'solve',true,@islogicalscalar, ...
    'sstate',false,@(x) islogical(x) || (iscell(x) && iscellstr(x(1:2:end))) ...
    || isfunc(x), ...
    'zero',false,@islogicalscalar, ...
    };

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
    'maxiter',[],@(x) isempty(x) || (isnumericscalar(x) && x >= 0), ...
    output{:}, ...
    'select',Inf,@(x) isequal(x,Inf) || ischar(x) || iscellstr(x), ...
    'tolerance',[],@(x) isempty(x) || (isnumericscalar(x) && x > 0), ...
    };

Def.filter = { ...
    'data,output','smooth',@(x) ischar(x), ...
    'refresh',true,@islogicalscalar, ...
    'rollback',[],@isnumeric, ...
    };

Def.fisher = { ...
    'chksgf',false,@islogicalscalar, ...
    'chksstate',true,@(x) islogicalscalar(x) ...
    || (iscell(x) && iscellstr(x(1:2:end))), ...
    'deviation',true,@islogicalscalar, ...
    'epspower',1/3,@isnumericscalar, ...
    'exclude',{},@(x) ischar(x) || iscellstr(x), ...
    'percent',false,@islogicalscalar, ...
    'progress',false,@islogicalscalar, ...
    'refresh',true,@islogicalscalar, ...
    'solve',true,@islogicalscalar, ...
    'sstate,sstateopt',false, ...
    @(x) islogical(x) || (iscell(x) && iscellstr(x(1:2:end))), ...
    'tolerance',eps()^(2/3),@isnumericscalar, ...
    };

Def.forecast = {...
    'anticipate',true,@islogicalscalar, ...
    deviation_dtrends{:}, ...
    'initcond','data',@(x) any(strcmpi(x,{'data','fixed'})) || isnumeric(x), ...
    'meanonly',false,@islogicalscalar, ...
    'std',[],@(x) isstruct(x) || isempty(x), ...
    'tolmse',getrealsmall('mse'),@(x) isnumeric(x) && length(x) == 1, ...
    };

Def.jforecast = {...
    'anticipate',true,@islogicalscalar, ...
    'currentonly',true,@islogicalscalar, ...
    deviation_dtrends{:}, ...
    'initcond','data',@(x) any(strcmpi(x,{'data','fixed'})) || isnumeric(x), ...
    'meanonly',false,@islogicalscalar, ...
    'precision','double',@(x) ischar(x) && any(strcmpi(x,{'double','single'})), ...
    'progress',false,@islogicalscalar, ...
    'plan',[],@(x) isa(x,'plan') || isempty(x), ...
    'vary,std',[],@(x) isstruct(x) || isempty(x), ...
    };

Def.icrf = {...
    'delog',true,@islogicalscalar,...
    'log',[],@(x) isempty(x) || islogicalscalar(x), ...
    'size',[],@(x) isempty(x) || isnumericscalar(x), ...
    };

Def.ifrf = {...
    'select',Inf,@(x) isequal(x,Inf) || ischar(x) || iscellstr(x), ...
    };

Def.loglik = { ...
    'domain','time',@(x) any(strncmpi(x,{'t','f'},1)), ...
    'persist',false,@islogicalscalar, ...
    };

Def.fdlik = { ...
    'band',[2,Inf],@(x) isnumeric(x) && length(x) == 2, ...
    deviation_dtrends{:}, ...
    ... 'exclude',[],@(x) isempty(x) || ischar(x) || iscellstr(x) || islogical(x), ...
    'outoflik',{},@(x) ischar(x) || iscellstr(x), ...
    'relative',true,@islogicalscalar, ...
    'zero',true,@islogicalscalar, ...
    };

Def.lognormal = { ...
    'fresh',false,@islogicalscalar, ...
    'mean',true,@islogicalscalar, ...
    'median',true,@islogicalscalar, ...
    'mode',true,@islogicalscalar, ...
    'prctile,pctile,pct',[5,95],@(x) isnumeric(x) && all(round(x(:)) > 0 & round(x(:)) < 100), ...
    'prefix','lognormal',@(x) ischar(x) && ~isempty(x), ...
    'std',true,@islogicalscalar, ...
    };

Def.kalman = { ...
    'ahead',1,@(x) isnumericscalar(x) && x > 0 && x == round(x), ...    
    'chkexact',false,@islogicalscalar, ...
    'chkfmse',false,@islogicalscalar, ...
    deviation_dtrends{:}, ...
    'condition',[],@(x) isempty(x) || ischar(x) || iscellstr(x) || islogical(x), ...
    'returncont,contributions',false,@islogicalscalar, ...
    'initcond','stochastic',@(x) ...
    isstruct(x) ...
    || (ischar(x) && any(strcmpi(x,{'stochastic','fixed','optimal'}))), ...
    'lastsmooth',Inf,@(x) isempty(x) || isnumericscalar(x), ...
    'nonlinearise,nonlinearize',0,@(x) isnumericscalar(x) && x == round(x) && x >= 0, ...
    'outoflik',{},@(x) ischar(x) || iscellstr(x), ...
    'objfunc,objective','loglik',@(x) any(strcmpi(x,{'loglik','mloglik','-loglik','prederr'})), ...
    'objrange,objectivesample',Inf,@isnumeric, ...
    'pedindonly',false,@islogicalscalar, ...
    precision{:}, ...
    'plan',[],@(x) isa(x,'plan') || isempty(x), ...
    'progress',false,@islogicalscalar, ...
    'relative',true,@islogicalscalar, ...
    'vary,std',[],@(x) isempty(x) || isstruct(x), ...
    'simulate',{},@(x) iscell(x) && iscellstr(x(1:2:end)), ...
    'symmetric',true,@islogicalscalar, ...
    'tolerance',eps()^(2/3),@isnumeric, ...
    'tolmse',0,@(x) (ischar(x) && strcmpi(x,'auto')) || isnumericscalar(x), ...
    'weighting',[],@isnumeric, ...
    'meanonly',false,@islogicalscalar, ...
    'returnstd',true,@islogicalscalar, ...
    'returnmse',true,@islogicalscalar, ...
    };

Def.model = {
    'addlead',false,@islogicalscalar, ...
    'declareparameters',true,@islogicalscalar, ...
    'multiple,allowmultiple',false,@islogicalscalar, ...
    'assign',[],@(x) isempty(x) || isstruct(x), ...
    'comment','',@ischar, ...
    'epsilon',eps^(1/3),@isnumericscalar, ...
    'removeleads,removelead',false,@islogicalscalar, ...
    'linear',[],@(x) isempty(x) || islogical(x), ...
    'multipliername','Mu_Eq%g',@(x) ischar(x) && ~isempty(strfind(x,'%g')), ...
    'precision','double',@(x) any(strcmp(x,{'double','single'})), ...
    'quadratic',false,@islogicalscalar, ...
    'saveas','',@ischar, ...
    'sstateonly',false,@islogicalscalar, ...
    'std',NaN,@isnumericscalar, ...
    'tolerance',[],@(x) isempty(x) || (isnumericscalar(x) && x >= 0), ...
    'torigin',2000,@isnumericscalar, ...
    };

Def.neighbourhood = { ...
    'plot',true,@islogicalscalar, ...
    'progress',false,@islogicalscalar, ...
    'neighbourhood',[],@(x) isempty(x) || isstruct(x), ...
    };

Def.tcorule = { ...
    'beta',1,@isnumericscalar, ...
    'display',5000,@isnumericscalar, ...
    'ginverse',false,@islogicalscalar, ...
    'initexp',@eye,@(x) isnumeric(x) || isfunc(x), ...
    'maxiter',50000,@isnumericscalar, ...
    'reset',false,@islogicalscalar, ...
    'tolexp',1e-10,@isnumericscalar, ...
    'tolrule',1e-10,@isnumericscalar, ...
    'tolvalue',1e-6,@isnumericscalar, ...
    'warning',true,@islogicalscalar, ...
    };

Def.regress = { ...
    'acf',{},@(x) iscell(x) && iscellstr(x(1:2:end)), ...
    output{:}, ...
    };
    
Def.resample = { ...
    deviation_dtrends{:}, ...
    'method','montecarlo',@(x) isfunc(x) ...
    || (ischar(x) && any(strcmpi(x,{'montecarlo','bootstrap'}))), ...
    'progress',false,@islogicalscalar, ...
    'randominitcond,randomiseinitcond,randomizeinitcond,randomise,randomize',true,@(x) islogicalscalar(x) || (isnumericscalar(x) && x >= 0), ...
    'svdonly',false,@islogicalscalar, ...
    'statevector','alpha',@(x) ischar(x) && any(strcmpi(x,{'alpha','x'})), ...
    'vary',[],@(x) isempty(x) || isstruct(x), ...
    'wild',false,@islogicalscalar, ...
    };

Def.shockplot = { ...
    'dbplot',{},@(x) iscell(x) && iscellstr(x(1:2:end)), ...
    'deviation',true,@islogicalscalar, ...
    'dtrends,dtrend','auto',@(x) islogicalscalar(x) || isequal(x,'auto'), ...
    'simulate',{},@(x) iscell(x) && iscellstr(x(1:2:end)), ...
    'shocksize,size','std',@(x) (ischar(x) && strcmpi(x,'std')) || isnumeric(x), ...
    };

Def.simulate = { ...
    'anticipate',true,@islogicalscalar, ...
    'contributions,contribution',false,@islogicalscalar, ...
    'dboverlay,dbextend',false,@(x) islogicalscalar(x) || isstruct(x), ...
    deviation_dtrends{:}, ...
    'fast',true,@islogicalscalar, ...
    'ignoreshocks,ignoreshock,ignoreresiduals,ignoreresidual', ...
    false,@islogicalscalar, ...
    'plan',[],@(x) isa(x,'plan') || isempty(x), ...
    'progress',false,@islogicalscalar, ...
    'missing',NaN,@isnumeric, ...
    ... Options for non-linear simulations
    'nonlinearise,nonlinearize,nonlinear', ...
    0,@(x) isempty(x) || isnumeric(x), ...
    'addsstate',true,@islogicalscalar, ...
    'display', ...
    100,@(x) islogicalscalar(x) || (isnumericscalar(x) && x >= 0 && x == round(x)), ...
    'error',false,@islogicalscalar, ...
    'fillout',false,@islogicalscalar, ...
    'lambda',1,@(x) isnumericscalar(x) && all(x > 0 & x <= 1), ...
    'reducelambda,lambdafactor', ...
    0.5,@(x) isnumericscalar(x) && x > 0 && x <= 1, ...
    'maxiter',100,@isnumericscalar, ...
    'tolerance',1e-5,@isnumericscalar, ...
    'upperbound',1.5,@(x) isnumericscalar(x) && all(x > 1), ...
    };

Def.solve = { ...
    'expand',0,@(x) isnumeric(x) && length(x) == 1, ...
    'linear','auto',@(x) islogicalscalar(x) ...
    || (ischar(x) && strcmpi(x,'auto')), ...
    'logbook',false,@islogicalscalar, ...
    'error',false,@islogicalscalar, ...
    'forward',0,@(x) isnumeric(x) && length(x) == 1, ...
    'progress',false,@islogicalscalar, ...
    'refresh',true,@islogicalscalar, ...
    'select',true,@islogicalscalar, ...
    'symbolic',true,@islogicalscalar, ...
    'warning',true,@islogicalscalar, ...
    };

Def.sourcedb = { ...
    'ndraw',1,@(x) isnumericscalar(x) && x >= 0 && x == round(x), ...
    'ncol',1,@(x) isnumericscalar(x) && x >= 0 && x == round(x), ...
    deviation_dtrends{:}, ...
    'randomshocks,randomshock',false,@islogicalscalar, ...
    'residuals,residual',[],@(x) isempty(x) || isfunc(x), ...
    };

Def.srf = {...
    'log',[],@(x) isempty(x) || islogicalscalar(x), ...
    'delog',true,@islogicalscalar, ...
    'select',Inf,@(x) (isnumeric(x) && length(x) == 1 && isinf(x)) || iscellstr(x) || ischar(x), ...
    'size','std',@(x) (ischar(x) && strcmpi(x,'std')) || isnumericscalar(x), ...
    };

Def.sspace = { ...
    'triangular',true,@islogicalscalar, ...
    'removeinactive',false,@islogicalscalar, ...
    };

Def.sstate = { ...
    'linear','auto',@(x) isequal(x,'auto') ...
    || isequal(x,true) || isequal(x,false), ...
    };

Def.mysstateverbose = { ...
    mysstate{:}, ...
    'display','iter',@(x) isempty(x) || islogical(x) || isanychari(x,{'iter','final','off','notify','none'}), ...
    'warning',true,@islogicalscalar, ...
    };

Def.mysstatesilent = { ...
    mysstate{:}, ...
    'display','off',@(x) isempty(x) || islogical(x) || isanychari(x,{'iter','final','off','notify','none'}), ...
    'warning',false,@islogicalscalar, ...
    };

Def.sstatefile = { ...
    swap{:}, ...
    'growthnames,growthname','d?',@ischar, ...
    'time',true,@islogicalscalar, ...
    };

Def.system = { ...
    'linear','auto',@(x) islogicalscalar(x) ...
    || (ischar(x) && strcmpi(x,'auto')), ...
    'select',true,@islogicalscalar, ...
    'symbolic',true,@islogicalscalar, ...
    };

Def.VAR = { ...
    'acf',{},@(x) iscell(x) && iscellstr(x(1:2:end)), ...
    'order',1,@isnumericscalar, ...
    'constant,const',true,@islogicalscalar, ...
    };

Def.vma = {
    'select',Inf,@(x) isequal(x,Inf) || ischar(x) || iscellstr(x), ...
    output{:}, ...
    };

Def.xsf = {
    applyfilter{:}, ...
    output{:}, ...
    'progress',false,@islogicalscalar, ...
    'select',Inf,@(x) isequal(x,Inf) || ischar(x) || iscellstr(x), ...
    };

end
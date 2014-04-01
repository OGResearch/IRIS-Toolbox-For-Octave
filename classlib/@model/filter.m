function [This,Outp,V,Delta,Pe,SCov] = filter(This,Inp,Range,varargin)
% filter  Kalman smoother and estimator of out-of-likelihood parameters.
%
% Syntax
% =======
%
%     [M,Outp,V,Delta,PE,SCov] = filter(M,Inp,Range,...)
%
% Input arguments
% ================
%
% * `M` [ model ] - Solved model object.
%
% * `Inp` [ struct | cell ] - Input database or datapack from which the
% measurement variables will be taken.
%
% * `Range` [ numeric ] - Filter date range.
%
% Output arguments
% =================
%
% * `M` [ model ] - Model object with updates of std devs (if `'relative='`
% is true) and/or updates of out-of-likelihood parameters (if `'outoflik='`
% is non-empty).
%
% * `Outp` [ struct | cell ] - Output struct with smoother or prediction
% data.
%
% * `V` [ numeric ] - Estimated variance scale factor if the `'relative='`
% options is true; otherwise `V` is 1.
%
% * `Delta` [ struct ] - Database with estimates of out-of-likelihood
% parameters.
%
% * `PE` [ struct ] - Database with prediction errors for measurement
% variables.
%
% * `SCov` [ numeric ] - Sample covariance matrix of smoothed shocks;
% the covariance matrix is computed using shock estimates in periods that
% are included in the option `'objrange='` and, at the same time, contain
% at least one observation of measurement variables.
%
% Options
% ========
%
% * `'ahead='` [ numeric | *`1`* ] - Predictions will be computed this number
% of period ahead.
%
% * `'chkFmse='` [ `true` | *`false`* ] - Check the condition number of the
% forecast MSE matrix in each step of the Kalman filter, and return
% immediately if the matrix is ill-conditioned; see also the option
% `'fmseCondTol='`.
%
% * `'condition='` [ char | cellstr | *empty* ] - List of conditioning
% measurement variables. Condition time t|t-1 prediction errors (that enter
% the likelihood function) on time t observations of these measurement
% variables.
%
% * `'deviation='` [ `true` | *`false`* ] - Treat input and output data as
% deviations from balanced-growth path.
%
% * `'dtrends='` [ *'auto'* | `true` | `false` ] - Measurement data contain
% deterministic trends.
%
% * `'data='` [ `'predict'` | *`'smooth'`* | `'predict,smooth'` ] - Return
% smoother data or prediction data or both.
%
% * `'fmseCondTol='` [ *`eps()`* | numeric ] - Tolerance for the FMSE
% condition number test; not used unless `'chkFmse=' true`.
%
% * `'initCond='` [ `'fixed'` | `'optimal'` | *`'stochastic'`* | struct ] -
% Method or data to initialise the Kalman filter; user-supplied initial
% condition must be a mean database or a mean-MSE struct.
%
% * `'lastSmooth='` [ numeric | *`Inf`* ] - Last date up to which to smooth
% data backward from the end of the range; if `Inf` smoother will run on the
% entire range.
%
% * `'meanOnly='` [ `true` | *`false`* ] - Return a plain database with
% mean data only; this option overrides the `'return*='` options, i.e.
% `'returnCont='`, `'returnMse='`, `'returnStd='`.
%
% * `'outOfLik='` [ cellstr | empty ] - List of parameters in deterministic
% trends that will be estimated by concentrating them out of the likelihood
% function.
%
% * `'objFunc='` [ *`'-loglik'`* | `'prederr'` ] - Objective function
% computed; can be either minus the log likelihood function or weighted sum
% of prediction errors.
%
% * `'objRange='` [ numeric | *`Inf`* ] - The objective function will be
% computed on the specified range only; `Inf` means the entire filter
% range.
%
% * `'precision='` [ *`'double'`* | `'single'` ] - Numeric precision to which
% output data will be stored; all calculations themselves always run to
% double precision.
%
% * `'relative='` [ *`true`* | `false` ] - Std devs of shocks assigned in the
% model object will be treated as relative std devs, and a common variance
% scale factor will be estimated.
%
% * `'returnCont='` [ `true` | *`false`* ] - Return contributions of
% measurement variables to the estimates of all variables and shocks.
%
% * `'returnMse='` [ *`true`* | `false` ] - Return MSE matrices for
% predetermined state variables; these can be used for settin up initial
% condition in subsequent call to another `filter` or `jforecast`.
%
% * `'returnStd='` [ *`true`* | `false` ] - Return database with std devs
% of model variables.
%
% * `'weighting='` [ numeric | *empty* ] - Weighting vector or matrix for
% prediction errors when `'objective=' 'prederr'`; empty means prediction
% errors are weighted equally.
%
% Options for models with non-linearised equations
% =================================================
%
% * `'nonlinear='` [ numeric | *`0`* ] - If non-zero the prediction step
% in the Kalman filter will be run in an exact non-linear mode using the
% same technique as [`model/simulate`](model/simulate).
%
% * `'simulate='` [ cell | empty ] - Options passed in to `simulate` when
% invoking the non-linear simulation in the prediction step; only used when
% `nonlinear=` is greater than `0`.
%
% Description
% ============
%
% The `'ahead='` and `'rollback='` options cannot be combined with one
% another, or with multiple data sets, or with multiple parameterisations.
%
% Initial conditions in time domain
% ----------------------------------
%
% By default (with `'initCond=' 'stochastic'`), the Kalman filter starts
% from the model-implied asymptotic distribution. You can change this
% behaviour by setting the option `'initCond='` to one of the following
% four different values:
%
% * `'fixed'` -- the filter starts from the model-implied asymptotic mean
% (steady state) but with no initial uncertainty. The initial condition is
% treated as a vector of fixed, non-stochastic, numbers.
%
% * `'optimal'` -- the filter starts from a vector of fixed numbers that
% is estimated optimally (likelihood maximising).
%
% * database (i.e. struct with fields for individual model variables) -- a
% database through which you supply the mean for all the required initial
% conditions, see help on [`model/get`](model/get) for how to view the list
% of required initial conditions.
%
% * mean-mse struct (i.e. struct with fields `.mean` and `.mse`) -- a struct
% through which you supply the mean and MSE for all the required initial
% conditions.
%
% Contributions of measurement variables to the estimates of all variables
% -------------------------------------------------------------------------
%
% Use the option `'returnCont=' true` to request the decomposition of
% measurement variables, transition variables, and shocks into the
% contributions of each individual measurement variable. The resulting
% output database will include one extra subdatabase called `.cont`. In
% the `.cont` subdatabase, each time series will have Ny columns where Ny
% is the number of measurement variables in the model. The k-th column will
% be the contribution of the observations on the k-th measurement variable.
%
% The contributions are additive for linearised variables, and
% multiplicative for log-linearised variables (log-variables). The
% difference between the actual path for a particular variable and the sum
% of the contributions (or their product in the case of log-varibles) is
% due to the effect of constant terms and deterministic trends.
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

nArgOut = nargout;

% Database with tunes.
j = [];
if ~isempty(varargin) && (isstruct(varargin{1}) || isempty(varargin{1}))
    j = varargin{1};
    varargin(1) = [];
end

pp = inputParser();
pp.addRequired('model',@is.model);
pp.addRequired('data',@(x) isstruct(x) || iscell(x) || isempty(x));
pp.addRequired('range',@isnumeric);
pp.addRequired('tune',@(x) isempty(x) || isstruct(x) || iscell(x));
pp.parse(This,Inp,Range,j);

% This FILTER function options.
[opt,varargin] = passvalopt('model.filter',varargin{:});

% Process Kalman filter options; `mypreploglik` also expands solution
% forward if needed for tunes on the mean of shocks.
Range = Range(1) : Range(end);
likOpt = mypreploglik(This,Range,'t',j,varargin{:});

% Get measurement and exogenous variables.
Inp = datarequest('yg*',This,Inp,Range);
nData = size(Inp,3);
nAlt = size(This.Assign,3);

% Check option conflicts.
doChkConflicts();

%--------------------------------------------------------------------------

ny = length(This.solutionid{1});
nb = size(This.solution{1},2);
xRange = Range(1)-1 : Range(end);
nXPer = length(xRange);

% Throw a warning if some of the data sets have no observations.
nanData = all(all(isnan(Inp),1),2);
if any(nanData)
    utils.warning('model', ...
        'No observations available in the input database%s.', ...
        sprintf(' #%g',(nanData)));
end

% Pre-allocated requested hdata output arguments.
hData = struct();
doPreallocHData();

% Run the Kalman filter.
[obj,regOutp,hData] = mykalman(This,Inp,hData,likOpt); %#ok<ASGLU>

% If needed, expand the number of model parameterizations to include
% estimated variance factors and/or out-of=lik parameters.
if nAlt < regOutp.NLoop && (likOpt.relative || ~isempty(regOutp.Delta))
    This = alter(This,regOutp.NLoop);
end

% Post-process regular (non-hdata) output arguments; update the std
% parameters in the model object if `'relative=' true`.
[~,Pe,V,Delta,~,SCov,This] = mykalmanregoutp(This,regOutp,xRange,likOpt);

% Post-process hdata output arguments.
Outp = hdataobj.hdatafinal(hData,This,xRange);


% Nested functions...


%**************************************************************************
    function doChkConflicts()
        if likOpt.ahead > 1 && (nData > 1 || nAlt > 1)
            utils.error('model', ...
                ['Cannot combine the option ''ahead='' greater than 1 ', ...
                'with multiple data sets or parameterisations.']);
        end
        if likOpt.returncont && any(likOpt.condition)
            utils.error('model', ...
                ['Cannot combine the option ''returnCont=true'' with ', ...
                'a non-empty option ''condition=''.']);
        end
    end % doChkConflicts()


%**************************************************************************
    function doPreallocHData()
        isPred = ~isempty(strfind(opt.data,'pred'));
        isFilter = ~isempty(strfind(opt.data,'filter'));
        isSmooth = ~isempty(strfind(opt.data,'smooth'));
        nLoop = max(nData,nAlt);
        nPred = max(nLoop,likOpt.ahead);
        if nArgOut >= 2
            % Prediction step.
            if isPred
                hData.predmean = hdataobj(This, ...
                    struct('IsPreSample',false, ...
                    'Precision',likOpt.precision), ...
                    nXPer,nPred);
                if ~likOpt.meanonly
                    if likOpt.returnstd
                        hData.predstd = hdataobj(This, ...
                            struct('IsPreSample',false, ...
                            'IsStd',true, ...
                            'Precision',likOpt.precision), ...
                            nXPer,nLoop);
                    end
                    if likOpt.returnmse
                        hData.predmse = nan(nb,nb,nXPer,nLoop, ...
                            likOpt.precision);
                    end
                    if likOpt.returncont
                        hData.predcont = hdataobj(This, ....
                            struct('IsPreSample',false, ...
                            'Precision',likOpt.precision, ...
                            'Contrib','Y'), ...
                            nXPer,ny);
                    end
                end
            end
            % Filter step.
            if isFilter
                hData.filtermean = hdataobj(This, ...
                    struct('IsPreSample',false, ...
                    'Precision',likOpt.precision), ...
                    nXPer,nLoop);
                if ~likOpt.meanonly
                    if likOpt.returnstd
                        hData.filterstd = hdataobj(This, ...
                            struct('IsPreSample',false, ...
                            'IsStd',true, ...
                            'Precision',likOpt.precision), ...
                            nXPer,nLoop);
                    end
                    if likOpt.returnmse
                        hData.filtermse = nan(nb,nb,nXPer,nLoop, ...
                            likOpt.precision);
                    end
                    if likOpt.returncont
                        hData.filtercont = hdataobj(This, ...
                            struct('IsPreSample',false, ...
                            'Precision',likOpt.precision, ...
                            'Contrib','Y'), ...
                            nXPer,ny);
                    end
                end
            end
            % Smooth data.
            if isSmooth
                hData.smoothmean = hdataobj(This, ...
                    struct('Precision',likOpt.precision), ...
                    nXPer,nLoop);
                if ~likOpt.meanonly
                    if likOpt.returnstd
                        hData.smoothstd = hdataobj(This, ...
                            struct('IsStd',true, ...
                            'Precision',likOpt.precision), ...
                            nXPer,nLoop);
                    end
                    if likOpt.returnmse
                        hData.smoothmse = nan(nb,nb,nXPer,nLoop, ...
                            likOpt.precision);
                    end
                    if likOpt.returncont
                        hData.smoothcont = hdataobj(This, ...
                            struct('Precision',likOpt.precision, ...
                            'Contrib','Y'), ...
                            nXPer,ny);
                    end
                end
            end
        end
    end % doPreallocHData()


end
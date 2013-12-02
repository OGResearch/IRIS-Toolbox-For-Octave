function [Obj,V,F,Pe,Delta,PDelta] = loglik(This,Data,Range,varargin)
% loglik  Evaluate minus the log-likelihood function in time or frequency domain.
%
% Full syntax
% ============
%
%     [Obj,V,F,PE,Delta,PDelta] = loglik(M,D,Range,...)
%
% Syntax for fast one-off likelihood evaluation
% ==============================================
%
%     Obj = loglik(M,D,Range,...)
%
% Syntax for repeated fast likelihood evaluations
% ================================================
%
%     % Step #1: Initialise.
%     loglik(M,D,Range,...,'persist=',true);
%
%     % Step #2: Assign/change parameters.
%     M... = ...; % Change parameters.
%
%     % Step #3: Re-compute steady state and solution if necessary.
%     M = ...;
%     M = ...;
%
%     % Step #4: Evaluate likelihood.
%     L = loglik(M);
%
%     % Repeat steps #2, #3, #4 for different values of parameters.
%     % ...
%
% Input arguments
% ================
%
% * `M` [ model ] - Model object on which the likelihood of the input data
% will be evaluated.
%
% * `D` [ struct | cell ] - Input database or datapack from which the
% measurement variables will be taken.
%
% * `Range` [ numeric ] - Date range.
%
% Output arguments
% =================
%
% Test title
% -----------
%
% * `Obj` [ numeric ] - Value of minus the log-likelihood function (or
% other objective function if specified in options).
%
% * `V` [ numeric ] - Estimated variance scale factor if the `'relative='`
% options is true; otherwise `V` is 1.
%
% * `F` [ numeric ] - Sequence of forecast MSE matrices for
% measurement variables.
%
% * `PE` [ struct ] - Database with prediction errors for measurement
% variables; exp of prediction errors for measurement variables declared as
% log-variables.
%
% * `Delta` [ struct ] - Databse with point estimates of the deterministic
% trend parameters specified in the `'outoflik='` option.
%
% * `PDelta` [ numeric ] - MSE matrix of the estimates of the `'outoflik='`
% parameters.
%
% Options
% ========
%
% * `'persist='` [ `true` | *`false`* ] -- Pre-process and store the overhead
% (data and options) for subsequent fast calls.
%
% See help on [`model/filter`](model/filter) for other options available.
%
% Description
% ============
%
% The number of output arguments you request when calling `loglik` affects
% computational efficiency. Running the function with only the first output
% argument, i.e. the value of the likelihood function (minus the log of it,
% in fact), results in the fastest performance.
%
% The `loglik` function runs an identical Kalman filter as
% [`model/filter`](model/filter), the only difference is the types and
% order of output arguments returned.
%
% Fast evaluation of likelihood
% ------------------------------
%
% Every time you change the parameters, you need to update the steady state
% and solution of the model if necessary by yourself, before calling
% `loglik`. Follow these rules:
%
% * If you only change std deviations and no other parameters, you don't
% have to re-calculate steady state or solution.
%
% * If the model is linear, you only need to call [`solve`](model/solve).
%
% * The only exception to rules #2 and #3 is when the model has [`dynamic
% links`](modellang/links) with references to some steady state values. In
% that case, you must also run [`sstate`](model/sstate) after
% [`solve`](model/solve) in linear models to update the steady state.
%
% * If the model is non-linear, and you only change parameters that affect
% transitory dynamics and not the steady state, you only need to call
% [`solve`](model/solve).
%
% * If the model is non-linear, and you change parameters that affect both
% transitory dynamics and steady state, you must run first
% [`sstate`](model/sstate) and then [`solve`](model/solve).
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

% These variables are cleared at the end of the file unless the user
% specifies `'persist=' true`.
persistent DATA RANGE OPT LIKOPT;

% If loglik(m) is called without any further input arguments, the last ones
% passed in will be used if `'persistent='` was set to `true`.
if nargin == 1
    if isempty(DATA)
        utils.error('model', ...
            ['You must first initialise model/loglik() before ', ...
            'running it in fast mode with one input argument.']);
    end
else
    tune = [];
    if ~isempty(varargin) ...
            && (isstruct(varargin{1}) || isempty(varargin{1}))
        tune = varargin{1};
        varargin(1) = [];
    end
    RANGE = Range;
    % Process `loglik` options.
    [OPT,varargin] = passvalopt('model.loglik',varargin{:});
    % Process `mykalman` and `myfdlik` options and initialise output data
    % handles.
    LIKOPT = mypreploglik(This,RANGE,OPT.domain,tune,varargin{:});
    % Get array of measurement and exogenous variables.
    DATA = datarequest('yg*',This,Data,RANGE,':',LIKOPT);
end

%--------------------------------------------------------------------------

% Evaluate likelihood
%---------------------
if nargout == 1
    Obj = LIKOPT.minusLogLikFunc(This,DATA,[],LIKOPT);
else
    [Obj,regOutp] = LIKOPT.minusLogLikFunc(This,DATA,[],LIKOPT);
    % Populate regular (non-hdata) output arguments.
    xRange = RANGE(1)-1 : RANGE(end);
    [F,Pe,V,Delta,PDelta] = mykalmanregoutp(This,regOutp,xRange,LIKOPT);
end

if ~OPT.persist
    DATA = [];
    RANGE = [];
    OPT = [];
    LIKOPT = [];
end

end
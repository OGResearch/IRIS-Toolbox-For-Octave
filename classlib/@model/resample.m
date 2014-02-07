function Outp = resample(This,Inp,Range,NDraw,varargin)
% resample  Resample from the model implied distribution.
%
% Syntax
% =======
%
%     Outp = resample(M,Inp,Range,NDraw,...)
%     Oupt = resample(M,Inp,Range,NDraw,J,...)
%
% Input arguments
% ================
%
% * `M` [ model ] - Solved model object.
%
% * `Inp` [ struct | empty ] - Input data (if needed) for the
% distributions of initial condition and/or empirical shocks; if not
% bootstrap is invovled
%
% * `Range` [ numeric ] - Resampling date range.
%
% * `NDraw` [ numeric ] - Number of draws.
%
% * `J` [ struct | empty ] - Database with user-supplied (time-varying)
% tunes on std devs, corr coeffs, and/or means of shocks.
%
% Output arguments
% =================
%
% * `Outp` [ struct ] - Output database with resampled data.
%
% Options
% ========
%
% * `'deviation='` [ `true` | *`false`* ] - Treat input and output data as
% deviations from balanced-growth path.
%
% * `'dtrends='` [ *`'auto'`* | `true` | `false` ] - Add deterministic trends to
% measurement variables.
%
% * `'method='` [ `'bootstrap'` | *`'montecarlo'`* ] - Method of
% randomising shocks and initial condition.
%
% * `'progress='` [ `true` | *`false`* ] - Display progress bar in the
% command window.
%
% * `'randomInitCond='` [ *`true`* | `false` | numeric ] - Randomise
% initial condition; a number means the initial condition will be simulated
% using the specified number of extra pre-sample periods.
%
% * `'stateVector='` [ *`'alpha'`* | `'x'` ] - When resampling initial
% condition, use the transformed state vector, `alpha`, or the vector of
% original variables, `x`; this option is meant to guarantee replicability
% of results.
%
% * `'svdOnly='` [ `true` | *`false`* ] - Do not attempt Cholesky and only
% use SVD to factorize the covariance matrix when resampling initial
% condition; only applies when `'randomInitCond=' true`.
%
% * `'wild='` [ `true` | *`false`* ] - Use wild bootstrap instead of Efron
% bootstrap; only applies when `'method=' 'bootstrap'`.
%
% Description
% ============
%
% When you use wild bootstrap for resampling the initial condition, the
% results are based on an assumption that the mean of the initial condition
% is the asymptotic mean implied by the model (i.e. the steady state).
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

% Called `resample(This,Inp,Range,NDraw,J,...)'
J = [];
if ~isempty(varargin) && isstruct(varargin{1})
    % Tunes on means and std devs of shocks.
    % filter(this,data,range,tunes,options...)
    % TODO: tunes on means of shocks.
    J = varargin{1};
    varargin(1) = [];
end

try
    NDraw; %#ok<VUNUS>
catch %#ok<CTCH>
    NDraw = 1;
end

% Parse required input arguments.
pp = inputParser();
if ismatlab
pp.addRequired('M',@is.model);
pp.addRequired('Inp',@(x) isnumeric(x) || isstruct(x) || is.tseries(x));
pp.addRequired('Range',@(x) isnumeric(x));
pp.addRequired('NDraw',@(x) is.numericscalar(x));
pp.addRequired('J',@(x) isempty(x) || isstruct(x));
pp.parse(This,Inp,Range,NDraw,J);
else
pp = pp.addRequired('M',@is.model);
pp = pp.addRequired('Inp',@(x) isnumeric(x) || isstruct(x) || is.tseries(x));
pp = pp.addRequired('Range',@(x) isnumeric(x));
pp = pp.addRequired('NDraw',@(x) is.numericscalar(x));
pp = pp.addRequired('J',@(x) isempty(x) || isstruct(x));
pp = pp.parse(This,Inp,Range,NDraw,J);
end

% Parse options.
opt = passvalopt('model.resample',varargin{:});

% If `'dtrends='` option is `'auto'` switch on/off the dtrends according to
% `'deviation='`.
if ischar(opt.dtrends) && strcmpi(opt.dtrends,'auto')
    opt.dtrends = ~opt.deviation;
end

% `nInit` is the number of pre-sample periods used to resample the initial
% condition if user does not wish to factorise the covariance matrix.
nInit = 0;
if isnumeric(opt.randominitcond)
    if isequal(opt.method,'bootstrap') && opt.wild
        utils.error('model', ...
            'Cannot pre-simulate initial conditions in wild bootstrap.');
    else
        nInit = round(opt.randominitcond);
        opt.randominitcond = false;
    end
end

if isequal(opt.method,'bootstrap') && isempty(Inp)
    utils.error('model', ...
        'Cannot bootstrap when there are no input data.');
end

if ischar(opt.method)
    opt.method = lower(opt.method);
end

%--------------------------------------------------------------------------

Range = Range(1) : Range(end);
XRange = Range(1)-1 : Range(end);
nPer = length(Range);
nXPer = length(XRange);
realSmall = getrealsmall();
nAlt = size(This.Assign,3);

% Cannot resample from multiple parameterisations.
if nAlt > 1
    utils.error('model', ...
        ['Cannot resample from model objects ', ...
        'with multiple parameterisations.']);
end

ny = sum(This.nametype == 1);
nx = size(This.solution{1},1);
nb = size(This.solution{1},2);
nf = nx - nb;
ne = sum(This.nametype == 3);

[T,R,K,Z,H,D,U,Omg] = mysspace(This,1,false);

% Pre-allocate output data.
hData = hdataobj(This,[],nXPer,NDraw);

% Return immediately if solution is not available.
if any(isnan(T(:)))
    utils.warning('model', ...
        'Solution(s) not available: #1.');
    % Convert emptpy hdataobj to tseries database.
    Outp = hdata2tseries(hData,This,XRange);
    return
end

nUnit = sum(abs(abs(This.eigval)-1) <= realSmall);
nStable = nb - nUnit;
Ta = T(nf+1:end,:);
Ra = R(nf+1:end,:);
Ta2 = Ta(nUnit+1:end,nUnit+1:end);
Ra2 = Ra(nUnit+1:end,:);

% Combine user-supplied stdcorr with model stdcorr.
usrStdcorr = mytune2stdcorr(This,Range,J,opt);
usrStdcorrInx = ~isnan(usrStdcorr);

% Get tunes on the mean of shocks.
isShockMean = false;
if ~isempty(J)
    shockMean = datarequest('e',This,J,Range);
    isShockMean = any(shockMean(:) ~= 0);
end

% Get exogenous variables in dtrend equations.
if opt.dtrends
    G = datarequest('g',This,Inp,Range);
end

% Describe the distribution of initial conditions
%-------------------------------------------------
if isequal(opt.randominitcond,false)
    Ea = doUncMean();
elseif isequal(opt.method,'bootstrap')
    % (1) Bootstrap.
    if ~opt.wild
        % (1a) Efron boostrap.
        sourceAlpha = datarequest('alpha',This,Inp,Range);
    else
        % (1b) Wild bootstrap.
        sourceAlpha0 = datarequest('init',This,Inp,Range);
        Ea = doUncMean();
    end
else
    % (2) Monte Carlo or user-supplied sampler.
    if ~isempty(Inp)
        % (2a) User-supplied distribution.
        [Ea,~,~,Pa] = datarequest('init',This,Inp,Range);
        Ex = U*Ea;
        if isempty(Pa)
            opt.randominitcond = false;
        else
            if strcmpi(opt.statevector,'alpha')
                % (2ai) Resample `alpha` vector.
                Fa = covfun.factorise(Pa,opt.svdonly);
            else
                % (2aii) Resample original `x` vector.
                Px = U*Pa*U.';
                Ui = inv(U);
                Fx = covfun.factorise(Px,opt.svdonly);
            end
        end
    else
        % (2b) Asymptotic distribution.
        Ea = doUncMean();
        Fa = zeros(nb);
        Pa = zeros(nb);
        Pa(nUnit+1:end,nUnit+1:end) = covfun.acovf(Ta2,Ra2, ...
            [],[],[],[],[],Omg,This.eigval(nUnit+1:end),0);
        if strcmpi(opt.statevector,'alpha')
            % (2bi) Resample the `alpha` vector.
            Fa(nUnit+1:end,nUnit+1:end) = covfun.factorise( ...
                Pa(nUnit+1:end,nUnit+1:end),opt.svdonly);
        else
            % (2bii) Resample the original `x` vector.
            Ex = U*Ea;
            Px = U*Pa*U.';
            Ui = inv(U);
            Fx = covfun.factorise(Px,opt.svdonly);
        end
    end
end

% Describe the distribution of shocks
%-------------------------------------
if isequal(opt.method,'bootstrap')
    % (1) Bootstrap.
    sourceE = datarequest('e',This,Inp,Range);
else
    % (2) Monte Carlo.
    % TODO: Use `mycombinestdcorr` instead.
    stdcorr = permute(This.stdcorr,[2,3,1]);
    stdcorr = stdcorr(:,ones(1,nPer));
    % Combine the model object stdevs with the user-supplied stdevs.
    if any(usrStdcorrInx(:))
        stdcorr(usrStdcorrInx) = usrStdcorr(usrStdcorrInx);
    end
    % Add model-object std devs for pre-sample if random initial conditions
    % are obtained by simulation.
    if nInit > 0
        stdcorr = [stdcorr(:,ones(1,nInit)),stdcorr];
    end
    
    % Periods in which corr coeffs are all zero. In these periods, we simply
    % mutliply the standard normal shocks by std devs one by one. In all
    % other periods, we need to compute and factorize the entire cov matrix.
    zeroCorr = all(stdcorr(ne+1:end,:) == 0, 1);
    if any(~zeroCorr)
        Pe = nan(ne,ne,nInit+nPer);
        Fe = nan(ne,ne,nInit+nPer);
        Pe(:,:,~zeroCorr) = ...
            covfun.stdcorr2cov(stdcorr(:,~zeroCorr),ne);
        Fe(:,:,~zeroCorr) = covfun.factorise(Pe(:,:,~zeroCorr));
    end
    
    % If user supplies sampler, sample all shocks and inital conditions at
    % once. This allows for advanced user-supplied simulation methods, e.g.
    % latin hypercube.
    if isa(opt.method,'function_handle')
        presampledE = opt.method(ne*(nInit+nPer),NDraw);
        if opt.randominitcond
            presampledInitNoise = opt.method(nb,NDraw);
        end
    end
end

% Distinguish between transition and measurement residuals.
RInx = any(abs(R(:,1:ne)) > 0,1);
HInx = any(abs(H(:,1:ne)) > 0,1);

if opt.dtrends
    W = mydtrendsrequest(This,'range',Range,G,Inf);
end

% Create a command-window progress bar.
if opt.progress
    progress = progressbar('IRIS model.resample progress');
end

% Main loop
%-----------
for iDraw = 1 : NDraw
    e = doDrawShocks();
    % 
    if isShockMean
        e = e + shockMean;
    end
    a0 = doDrawInitCond();
    % Transition variables.
    w = nan(nx,nInit+nPer);
    w(:,1) = T*a0 + R(:,RInx)*e(RInx,1);
    if ~opt.deviation
        w(:,1) = w(:,1) + K;
    end
    for t = 2 : nInit+nPer
        w(:,t) = T*w(nf+1:end,t-1) + R(:,RInx)*e(RInx,t);
        if ~opt.deviation
            w(:,t) = w(:,t) + K;
        end
    end
    % Measurement variables.
    y = Z*w(nf+1:end,nInit+1:end) + H(:,HInx)*e(HInx,nInit+1:end);
    if ~opt.deviation
        y = y + D(:,ones(1,nPer));
    end
    if opt.dtrends
        y = y + W(:,:,min(iDraw,end));
    end
    % Store this draw.
    doStoreDraw();
    % Update the progress bar.
    if opt.progress
        update(progress,iDraw/NDraw);
    end
end

% Convert hdataobj to tseries database.
Outp = hdata2tseries(hData,This,XRange);

% Nested functions.

%**************************************************************************
    function Ea = doUncMean()
        Ea = zeros(nb,1);
        if ~opt.deviation
            Ka2 = K(nf+nUnit+1:end,:);
            Ea(nUnit+1:end) = (eye(nStable) - Ta2) \ Ka2;
        end
    end % doUncMean().

%**************************************************************************
    function e = doDrawShocks()
        % Resample residuals.
        if isequal(opt.method,'bootstrap')
            % In boostrap, `ninit` is always zero.
            if opt.wild
                % Wild bootstrap.
                draw = randn(1,nPer);
                % To reproduce input sample: draw = ones(1,nper);
                e = sourceE.*draw(ones(1,ne),:);
            else
                % Standard Efron bootstrap.
                % draw is uniform on [1,nper].
                draw = randi([1,nPer],[1,nInit+nPer]);
                % To reproduce input sample: draw = 0 : nper-1;
                e = sourceE(:,draw);
            end
        else
            if isa(opt.method,'function_handle')
                % Fetch and reshape the presampled shocks.
                thisSampleE = presampledE(:,iDraw);
                thisSampleE = reshape(thisSampleE,[ne,nInit+nPer]);
            else
                % Draw shocks from standardised normal.
                thisSampleE = randn(ne,nInit+nPer);
            end
            % Scale standardised normal by the std devs.
            e = zeros(ne,nInit+nPer);
            e(:,zeroCorr) = ...
                stdcorr(1:ne,zeroCorr) .* thisSampleE(:,zeroCorr);
            if any(~zeroCorr)
                % Some corrs are non-zero.
                for i = find(~zeroCorr)
                    e(:,i) = Fe(:,:,i)*thisSampleE(:,i);
                end
            end
        end
    end % doDrawShocks().

%**************************************************************************
    function a0 = doDrawInitCond()
        % Randomise initial condition for stable alpha.
        if isequal(opt.method,'bootstrap')
            % Bootstrap from empirical distribution.
            if opt.randominitcond
                if opt.wild
                    % Wild-bootstrap initial condition for alpha from given
                    % sample initial condition. This assumes that the mean is
                    % the unconditional distribution.
                    a0 = [ ...
                        sourceAlpha0(1:nUnit,1); ...
                        Ea2 + randn()*(sourceAlpha0(nUnit+1:end,1) - Ea2); ...
                        ];
                else
                    % Efron-bootstrap init cond for alpha from sample.
                    draw = randi([1,nPer],1);
                    a0 = sourceAlpha(:,draw);
                end
            else
                % Fix init cond to unconditional mean.
                a0 = Ea;
            end
        else
            % Gaussian Monte Carlo from theoretical distribution.
            if opt.randominitcond
                if isa(opt.method,'function_handle')
                    % Fetch the pre-sampled initial conditions.
                    initNoise = presampledInitNoise(:,iDraw);
                else
                    % Draw from standardised normal.
                    initNoise = randn(nb,1);
                end
                if strcmpi(opt.statevector,'alpha')
                    a0 = Ea + Fa*initNoise;
                else
                    x0 = Ex + Fx*initNoise;
                    a0 = Ui*x0;
                end
            else
                % Fix initial conditions to mean.
                a0 = Ea;
            end
        end
    end % doDrawInitCond().

%**************************************************************************
    function doStoreDraw()
        if nInit == 0
            init = a0;
        else
            init = w(nf+1:end,nInit);
        end
        xf = [nan(nf,1),w(1:nf,nInit+1:end)];
        xb = U*[init,w(nf+1:end,nInit+1:end)];
        hdataassign(hData,This,iDraw, ...
            [nan(ny,1),y], ...
            [xf;xb], ...
            [nan(ne,1),e(:,nInit+1:end)]);
    end % doStoreDraw().

end
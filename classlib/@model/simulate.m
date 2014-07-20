function [Outp,ExitFlag,AddFact,Discr] = simulate(This,Inp,Range,varargin)
% simulate  Simulate model.
%
%
% Syntax
% =======
%
%     S = simulate(M,D,Range,...)
%     [S,Flag,AddF,Discrep] = simulate(M,D,Range,...)
%
%
% Input arguments
% ================
%
% * `M` [ model ] - Solved model object.
%
% * `D` [ struct | cell ] - Input database or datapack from which the
% initial conditions and shocks from within the simulation range will be
% read.
%
% * `Range` [ numeric ] - Simulation range.
%
%
% Output arguments
% =================
%
% * `S` [ struct | cell ] - Database with simulation results.
%
%
% Output arguments in non-linear simulations
% ===========================================
%
% * `Flag` [ cell | empty ] - Cell array with exit flags for non-linearised
% simulations.
%
% * `AddF` [ cell | empty ] - Cell array of tseries with final add-factors
% added to first-order approximate equations to make non-linear equations
% hold.
%
% * `Discrep` [ cell | empty ] - Cell array of tseries with final
% discrepancies between LHS and RHS in equations marked for non-linear
% simulations by a double-equal sign.
%
%
% Options
% ========
%
% * `'anticipate='` [ *`true`* | `false` ] - If `true`, real future shocks are
% anticipated, imaginary are unanticipated; vice versa if `false`.
%
% * `'contributions='` [ `true` | *`false`* ] - Decompose the simulated paths
% into contributions of individual shocks.
%
% * `'deviation='` [ `true` | *`false`* ] - Treat input and output data as
% deviations from balanced-growth path.
%
% * `'dbOverlay='` [ `true` | *`false`* | struct ] - Use the function
% `dboverlay` to combine the simulated output data with the input database,
% or with another database, at the end.
%
% * `'dTrends='` [ *`@auto`* | `true` | `false` ] - Add deterministic trends to
% measurement variables.
%
% * `'ignoreShocks='` [ `true` | *`false`* ] - Read only initial conditions from
% input data, and ignore any shocks within the simulation range.
%
% * `'plan='` [ plan ] - Specify a simulation plan to swap endogeneity
% and exogeneity of some variables and shocks temporarily, and/or to
% simulate some of the non-linear equations accurately.
%
% * `'progress='` [ `true` | *`false`* ] - Display progress bar in the command
% window.
%
%
% Options in nonlinear simualations
% ==================================
%
% * `'addSstate='` [ *`true`* | `false` ] - Add steady state levels to
% simulated paths before evaluating non-linear equations; this option is
% used only if `'deviation=' true`.
%
% * `'display='` [ *`true`* | `false` | numeric | Inf ] - Report iterations
% on the screen; if `'display=' N`, report every `N` iterations; if
% `'display=' Inf`, report only final iteration.
%
% * `'error='` [ `true` | *`false`* ] - Throw an error whenever a
% non-linear simulation fails converge; if `false`, only an warning will
% display.
%
% * `'lambda='` [ numeric | *`1`* ] - Step size (between `0` and `1`)
% for add factors added to non-linearised equations in every iteration.
%
% * `'reduceLambda='` [ numeric | *`0.5`* ] - Factor (between `0` and
% `1`) by which `lambda` will be multiplied if the non-linear simulation
% gets on an divergence path.
%
% * `'maxIter='` [ numeric | *`100`* ] - Maximum number of iterations.
%
% * `'tolerance='` [ numeric | *`1e-5`* ] - Convergence tolerance.
%
%
% Description
% ============
%
% Output range
% -------------
%
% Time series in the output database, `S`, are are defined on the
% simulation range, `Range`, plus include all necessary initial conditions,
% i.e. lags of variables that occur in the model code. You can use the
% option `'dboverlay='` to combine the output database with the input
% database (i.e. to include a longer history of data in the simulated
% series).
%
%
% Deviations from steady-state and deterministic trends
% ------------------------------------------------------
%
% By default, both the input database, `D`, and the output database, `S`,
% are in full levels and the simulated paths for measurement variables
% include the effect of deterministic trends, including possibly exogenous
% variables. The default behavior can be changed by changing the options
% `'deviation='` and `'dTrends='`.
%
% The default value for `'deviation='` is false. If set to `true`, then the
% input database is expected to contain data in the form of deviations from
% their steady state levels or paths. For ordinary variables (i.e.
% variables whose log status is `false`), it is $x_t-\Bar x_t$, meaning
% that a 0 indicates that the variable is at its steady state and e.g. 2
% indicates the variables exceeds its steady state by 2. For log-variables
% (i.e. variables whose log status is `true`), it is $x_t/\Bar x_t$,
% meaning that a 1 indicates that the variable is at its steady state and
% e.g. 1.05 indicates that the variable is 5 per cent above its steady
% state.
%
% The default value for `'dTrends='` is `@auto`. This means that its
% behavior depends on the option `'deviation='`. If `'deviation=' false`
% then deterministic trends are added to measurement variables, unless you
% manually override this behavior by setting `'dTrends=' false`.  On the
% other hand, if `'deviation=' true` then deterministic trends are not
% added to measurement variables, unless you manually override this
% behavior by setting `'dTrends=' true`.
%
%
% Simulating contributions of shocks
% -----------------------------------
%
% Use the option `'contributions=' true` to request the contributions of
% shocks to the simulated path for each variable; this option cannot be
% used in models with multiple alternative parameterizations or with
% multiple input data sets.
%
% The output database, `S`, contains Ne+2 columns for each variable, where
% Ne is the number of shocks in the model:
%
% * the first columns 1...Ne are the
% contributions of the Ne individual shocks to the respective variable;
%
% * column Ne+1 is the contribution of initial condition, th econstant, and
% deterministic trends, including possibly exogenous variables;
%
% * column Ne+2 is the contribution of nonlinearities in nonlinear
% simulations (it is always zero otherwise).
%
% The contributions are additive for ordinary variables (i.e. variables
% whose log status is `false`), and multplicative for log varibles (i.e.
% variables whose log status is `true`). In other words, if `S` is the
% output database from a simulation with `'contributions=' true`, `X` is an
% ordinary variable, and `Z` is a log variable, then
%
%     sum(S.X,2)
%
% (i.e. the sum of all Ne+2 contributions in each period, i.e. summation
% goes across 2nd dimension) reproduces the final simulated path for
% the variable `X`, whereas
%
%     prod(S.Z,2)
%
% (i.e. the product of all Ne+2 contributions) reproduces the final
% simulated path for the variable `Z`.
%
%
% Simulations with multiple parameterisations and/or multiple data sets
% ----------------------------------------------------------------------
%
% If you simulate a model with `N` parameterisations and the input database
% contains `K` data sets (i.e. each variable is a time series with `K`
% columns), then the following happens:
%
% * The model will be simulated a total of `P = max(N,K)` number of times.
% This means that each variables in the output database will have `P`
% columns.
%
% * The 1st parameterisation will be simulated using the 1st data set, the
% 2nd parameterisation will be simulated using the 2nd data set, etc. until
% you reach either the last parameterisation or the last data set, i.e.
% `min(N,K)`. From that point on, the last parameterisation or the last
% data set will be simply repeated (re-used) in the remaining simulations.
%
% * Put formally, the `I`-th column in the output database, where `I = 1,
% ..., P`, is a simulation of the `min(I,N)`-th model parameterisation
% using the `min(I,K)`-th input data set number.
%
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

% Parse required inputs.
pp = inputParser();
pp.addRequired('D',@(x) isstruct(x) || iscell(x));
pp.addRequired('Range',@isnumeric);
pp.parse(Inp,Range);

% Parse options.
opt = passvalopt('model.simulate',varargin{:});

%--------------------------------------------------------------------------

% Input struct to the backend functions in `+simulate` package.
s = struct();

ny = sum(This.nametype == 1);
nx = size(This.solution{1},1);
nb = size(This.solution{1},2);
nf = nx - nb;
ne = sum(This.nametype == 3);
ng = sum(This.nametype == 5);
nAlt = size(This.Assign,3);

Range = Range(1) : Range(end);
nPer = length(Range);
s.NPer = nPer;

% Simulation plan.
isPlan = isa(opt.plan,'plan');
isTune = isPlan && nnzendog(opt.plan) > 0 && nnzexog(opt.plan) > 0;
isNonlinPlan = any(This.IxNonlin) ...
    && (isPlan && nnznonlin(opt.plan) > 0);
isNonlinOpt = any(This.IxNonlin) ...
    && ~isempty(opt.nonlinearise) && opt.nonlinearise > 0;
s.IsNonlin = isNonlinPlan || isNonlinOpt;
s.IsDeviation = opt.deviation;
s.IsAddAstate = opt.addsstate;

% Get initial condition for alpha.
% alpha is always expanded to match nalt within `datarequest`.
[aInit,xInit,nanInit] = datarequest('init',This,Inp,Range);
if ~isempty(nanInit)
    if isnan(opt.missing)
        nanInit = unique(nanInit);
        utils.error('model:simulate', ...
            'This initial condition is not available: ''%s''.', ...
            nanInit{:});
    else
        aInit(isnan(aInit)) = opt.missing;
    end
end
nInit = size(aInit,3);

% Get shocks; both reals and imags are checked for NaNs within
% `datarequest`.
if ~opt.ignoreshocks
    Ee = datarequest('e',This,Inp,Range);
    % Find the last anticipated shock to determine t+k for expansion.
    if opt.anticipate
        lastEa = utils.findlast(real(Ee));
    else
        lastEa = utils.findlast(imag(Ee));
    end
    nShock = size(Ee,3);
else
    lastEa = 0;
    nShock = 0;
end

% Check for option conflicts.
doChkConflicts();

% Simulation range and plan range must be identical.
if isPlan
    [yAnch,xAnch,eaReal,eaImag,~,~,s.QAnch,wReal,wImag] = ...
        myanchors(This,opt.plan,Range);
end

% Nonlinearised simulation through the option `'nonlinearise='`.
if isNonlinOpt
    if isintscalar(opt.nonlinearise)
        qStart = 1;
        qEnd = opt.nonlinearise;
    else
        qStart = round(opt.nonlinearise(1) - Range(1) + 1);
        qEnd = round(opt.nonlinearise(end) - Range(1) + 1);
    end
    s.QAnch = false(1,max(nPer,qEnd));
    s.QAnch(1,qStart:qEnd) = true;
end

if isTune
    s.YAnch = yAnch;
    s.XAnch = xAnch;
    if opt.anticipate
        % Positions of anticipated and unanticipated endogenised shocks.
        s.EaAnch = eaReal;
        s.EuAnch = eaImag;
        % Weights (std devs) of anticipated and unanticipated endogenised shocks.
        % These will be only used in underdetermined systems.
        s.WghtA = wReal;
        s.WghtU = wImag;
    else
        s.EaAnch = eaImag;
        s.EuAnch = eaReal;
        s.WghtA = wImag;
        s.WghtU = wReal;
    end
    lastEndgA = utils.findlast(s.EaAnch);
    lastEndgU = utils.findlast(s.EuAnch);
    % Get actual values for exogenised data points.
    Yy = datarequest('y',This,Inp,Range);
    Xx = datarequest('x',This,Inp,Range);
    % Check for NaNs in exogenised variables.
    doChkNanExog();
    % Check the number of exogenised and endogenised data points
    % (exogenising must always be an exactly determined system).
    nTune = max(size(Yy,3),size(Xx,3));
else
    nTune = 0;
    lastEndgA = 0;
    lastEndgU = 0;
    s.YAnch = [];
    s.XAnch = [];
    s.EaAnch = [];
    s.EuAnch = [];
    s.WghtA = [];
    s.WghtU = [];
end

% Get exogenous variables in dtrend equations.
G = datarequest('g',This,Inp,Range);
nExog = size(G,3);

% Total number of cycles.
nLoop = max([1,nAlt,nInit,nShock,nTune,nExog]);
s.NLoop = nLoop;

if s.IsNonlin
    s.NPerNonlin = utils.findlast(s.QAnch);
    % The field `zerothSegment` is used by the Kalman filter to report
    % the correct period.
    s.zerothSegment = 0;
    % Prepare output arguments for non-linear simulations.
    ExitFlag = cell(1,nLoop);
    AddFact = cell(1,nLoop);
    Discr = cell(1,nLoop);
    doChkNonlinConflicts();
    % Index of log-variables in the `xx` vector.
    s.IxXLog = This.IxLog(real(This.solutionid{2}));
else
    % Output arguments for non-linear simulations.
    s.NPerNonlin = 0;
    ExitFlag = {};
    AddFact = {};
    Discr = {};
end

% Initialise handle to output data.
xRange = Range(1)-1 : Range(end);
if ~opt.contributions
    hData = hdataobj(This,xRange,nLoop);
else
    hData = hdataobj(This,xRange,ne+2,'Contributions=',@shock);
end

% Maximum expansion needed.
s.TPlusK = max([1,lastEa,lastEndgA,s.NPerNonlin]) - 1;

% Create anonymous functions for retrieving anticipated and unanticipated
% values, and for combining anticipated and unanticipated values.
s = simulate.antunantfunc(s,opt.anticipate);

% Main loop
%-----------

isSol = true(1,nLoop);

if opt.progress && (This.IsLinear || opt.display == 0)
    s.progress = progressbar('IRIS model.simulate progress');
else
    s.progress = [];
end

for iLoop = 1 : nLoop
    s.iLoop = iLoop;
    
    if iLoop <= nAlt
        % Update solution and other data-independent info to be used in this
        % simulation round.
        s = myprepsimulate(This,s,iLoop);
    end
    
    % Simulation is not available, return immediately.
    if any(~isfinite(s.T(:)))
        isSol(iLoop) = false;
        continue
    end
        
    % Get current initial condition for the transformed state vector,
    % current shocks, and tunes on measurement and transition variables.
    doGetData();
    
    % Compute deterministic trends if requested. Do not compute the dtrends
    % in the `+simulate` package because they are dealt with differently when
    % called from within the Kalman filter.
    s.W = [];
    if ny > 0 && opt.dtrends
        s.W = mydtrendsrequest(This,'range',Range,s.G,iLoop);
        if isTune
            % Subtract deterministic trends from measurement tunes.
            s.YTune = s.YTune - s.W;
        end
    end
    
    % Call the backend package `simulate`
    %-------------------------------------
    exitFlag = [];
    discr = [];
    addFact = [];
    s.y = [];
    s.w = [];
    if s.IsNonlin
        % Simulate linear contributions of shocks.
        if opt.contributions
            useCon = simulate.contributions(s,Inf,opt);
        end
        % Simulate contributions of nonlinearities residually.
        s = simulate.findsegments(s);          
        [s,exitFlag,discr,addFact] = simulate.nonlinear(s,opt);
        if opt.contributions
            useCon.w(:,:,ne+2) = s.w - sum(useCon.w,3);
            useCon.y(:,:,ne+2) = s.y - sum(useCon.y,3);
            s = useCon;
        end
    else
        s.Count = 0;
        s.u = [];
        if opt.contributions
            s = simulate.contributions(s,Inf,opt);
        else
            s = simulate.linear(s,Inf,opt);
        end
    end
    
    % Diagnostics output arguments for non-linear simulations.
    if s.IsNonlin
        ExitFlag{iLoop} = exitFlag;
        Discr{iLoop} = discr;
        AddFact{iLoop} = addFact;
    end
    
    % Add measurement detereministic trends.
    if ny > 0 && opt.dtrends
        % Add to trends to the current simulation; when `'contributions='
        % true`, we need to add the trends to (ne+1)-th simulation
        % (i.e. the contribution of init cond and constant).
        if opt.contributions
            s.y(:,:,ne+1) = s.y(:,:,ne+1) + s.W;
        else
            s.y = s.y + s.W;
        end            
    end
    
    % Initial condition for the original state vector.
    s.x0 = xInit(:,1,min(iLoop,end));
    
    % Assign output data.
    doAssignOutp();
    
    % Add equation labels to add-factor and discrepancy series.
    if s.IsNonlin && nargout > 2
        label = s.label;
        nSegment = length(s.segment);
        AddFact{iLoop} = tseries(Range(1), ...
            permute(AddFact{iLoop},[2,1,3]),label(1,:,ones(1,nSegment)));
        Discr{iLoop} = tseries(Range(1), ...
            permute(Discr{iLoop},[2,1,3]),label);
    end

    % Update progress bar.
    if ~isempty(s.progress)
        update(s.progress,s.iLoop/s.NLoop);
    end
    
end
% End of main loop.

% Post mortem
%-------------

if isTune
    % Throw a warning if the system is not exactly determined.
    doChkDetermined();
end

% Report solutions not available.
if ~all(isSol)
    utils.warning('model:simulate', ...
        'Solution(s) not available %s.', ...
        preparser.alt2str(~isSol));
end

% Convert hdataobj to struct. The comments assigned to the output series
% depend on whether this is a `'contributions=' true` simulation or not.
Outp = hdata2tseries(hData);

% Overlay the input (or user-supplied) database with the simulation
% database.
if isequal(opt.dboverlay,true)
    Outp = dboverlay(Inp,Outp);
elseif isstruct(opt.dboverlay)
    Outp = dboverlay(opt.dboverlay,Outp);
end


% Nested functions...


%**************************************************************************


    function doChkNanExog()
        % Check for NaNs in exogenised variables.
        inx1 = [s.YAnch;s.XAnch];
        inx2 = [any(~isfinite(Yy),3);any(~isfinite(Xx),3)];
        inx3 = [any(imag(Yy) ~= 0,3);any(imag(Xx) ~= 0,3)];
        inx = any(inx1 & (inx2 | inx3),2);
        if any(inx)
            list = myvector(This,'yx');
            utils.error('model:simulate', ...
                ['This variable is exogenised to NaN, Inf or ', ...
                'complex number: ''%s''.'], ...
                list{inx});
        end
    end % doChkNanExog()


%**************************************************************************


    function doChkDetermined()
        if nnzexog(opt.plan) ~= nnzendog(opt.plan)
            utils.warning('model:simulate', ...
                ['The number of exogenised data points (%g) does not ', ...
                'match the number of endogenised data points (%g).'], ...
                nnzexog(opt.plan),nnzendog(opt.plan));
        end
    end % doChkDetermined()


%**************************************************************************


    function doAssignOutp()
        n = size(s.w,3);
        xf = [nan(nf,1,n),s.w(1:nf,:,:)];
        alp = s.w(nf+1:end,:,:);
        xb = nan(size(alp));
        for ii = 1 : n
            xb(:,:,ii) = s.U*alp(:,:,ii);
        end
        % Add initial condition to xb.
        if opt.contributions
            pos = 1 : ne+2;
            xb = [zeros(nb,1,ne+2),xb];
            xb(:,1,ne+1) = s.x0;
            g = zeros(ng,nPer,ne+2);
            g(:,:,ne+1) = s.G;
        else
            pos = iLoop;
            xb = [s.x0,xb];
            g = s.G;
        end
        % Add current results to output data.
        hdataassign(hData,pos, ...
            { ...
            [nan(ny,1,n),s.y], ...
            [xf;xb], ...
            [nan(ne,1,n),s.e], ...
            [], ...
            [nan(ng,1,n),g], ...
            });
    end % doAssignOutput()


%**************************************************************************


    function doChkConflicts()
        % The option `'contributions='` option cannot be used with the
        % `'plan='` option, with multiple parameterisations, or multiple
        % data sets.
        if opt.contributions
            if isTune
                utils.error('model:simulate', ...
                    ['Cannot run simulation with ''contributions='' true ', ...
                    'and non-empty ''plan=''.']);
            end
            if nAlt > 1 || nInit > 1 || nShock > 1
                utils.error('model:simulate', ...
                    ['Cannot run simulation with ''contributions='' true ', ...
                    'in models with multiple alternative parameterizations.']);
            end
            if nInit > 1 || nShock > 1
                utils.error('model:simulate', ...
                    ['Cannot run simulation with ''contributions='' true ', ...
                    'and input database with multiple data sets.']);
            end
        end
    end % doChkConflicts()


%**************************************************************************


    function doChkNonlinConflicts()
        if lastEndgU > 0 && lastEndgA > 0
            utils.error('model:simulate', ...
                ['Non-linearised simulations cannot combine ', ...
                'anticipated and unanticipated endogenised shocks.']);
        end
    end % doChkNonlinConflicts()


%**************************************************************************


    function doGetData()        
        % Get current initial condition for the transformed state vector,
        % and current shocks.
        s.a0 = aInit(:,1,min(iLoop,end));
        if ~opt.ignoreshocks
            s.e = Ee(:,:,min(iLoop,end));
        else
            s.e = zeros(ne,nPer);
        end        
        % Current tunes on measurement and transition variables.
        s.YTune = [];
        s.XTune = [];
        if isTune
            s.YTune = Yy(:,:,min(iLoop,end));
            s.XTune = Xx(:,:,min(iLoop,end));
        end
        % Exogenous variables in dtrend equations.
        s.G = G(:,:,min(iLoop,end));
    end % doGetData()


end

function [Obj,RegOutp,HData] = mykalman(This,Inp,HData,Opt,varargin)
% mykalman  [Not a public function] Kalman filter.
%
% Backed IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

% This Kalman filter handles the following special cases:
% * non-stationary initial conditions (treated as fixed numbers);
% * measurement parameters concentrated out of likelihood;
% * time-varying std deviations;
% * conditioning of likelihood upon some measurement variables;
% * exclusion of some of the periods from likelihood;
% * k-step-ahead predictions;
% * tunes on the mean of shocks, combined anticipated and unanticipated;
% * missing observations entered as NaNs;
% * infinite std devs of measurement shocks equivalent to missing obs.
% * contributions of measurement variables to transition variables.

try
    Opt.initmeanunit;
catch
    Opt.initmeanunit = 'optimal';
end

nao = nargout;
ny = length(This.solutionid{1});
nx = size(This.solution{1},1);
nb = size(This.solution{1},2);
nf = nx - nb;
ne = length(This.solutionid{3});
ng = sum(This.nametype == 5);
nEqtn = length(This.eqtn);
nAlt = size(This.Assign,3);
nData = size(Inp,3);

%--------------------------------------------------------------------------

s = struct();
s.isnonlin = Opt.nonlinearise > 0 && any(This.nonlin);
s.ahead = Opt.ahead;
s.isObjOnly = nao == 1;

realSmall = getrealsmall();

% Out-of-lik params cannot be used with ~opt.dtrends.
nPOut = length(Opt.outoflik);

% Extended number of periods including pre-sample.
nPer = size(Inp,2) + 1;

% Struct with currently processed information. Initialise the invariant
% fields.
s.ny = ny;
s.nx = nx;
s.nb = nb;
s.nf = nf;
s.ne = ne;
s.nalt = nAlt;
s.nper = nPer;
s.npout = nPOut;

% Add pre-sample to objective function range and deterministic time trend.
s.objrange = [false,Opt.objrange];
s.ttrend = [nan,Opt.ttrend];

% Do not adjust the option `'lastSmooth='` -- see comments in `loglikopt`.
s.lastSmooth = Opt.lastsmooth;

% Tunes on shock means; model solution is expanded within `mypreploglik`.
tune = Opt.tune;
s.istune = ~isempty(tune) && any(tune(:) ~= 0);
if s.istune
    % Add pre-sample.
    nTune = size(tune,3);
    tune = [zeros(ne,1,nTune),tune];
end

% Total number of cycles.
nLoop = max(nData,nAlt);
s.nPred = max(nLoop,s.ahead);

% Pre-allocate output data.
if ~s.isObjOnly
    doRequestOutp();
end

% Pre-allocate the non-hdata output arguments.
Obj = nan(1,nLoop,Opt.precision);
if ~s.isObjOnly
    % Regular (non-hdata) output arguments.
    RegOutp = struct();
    RegOutp.F = nan(ny,ny,nPer,nLoop,Opt.precision);
    RegOutp.Pe = nan(ny,nPer,s.nPred,Opt.precision);
    RegOutp.V = nan(1,nLoop,Opt.precision);
    RegOutp.Delta = nan(nPOut,nLoop,Opt.precision);
    RegOutp.PDelta = nan(nPOut,nPOut,nLoop,Opt.precision);
    RegOutp.SampleCov = nan(ne,ne,nLoop);
end

% Indices of shocks occuring in measurement and transition equations.
[s.mshocks,s.tshocks] = myshocktypes(This);

% Prepare struct and options for non-linear simulations (prediction
% step).
s2 = struct();
if s.isnonlin
    doPrepareNonlin();
end

% Main loop
%-----------

if ~s.isObjOnly && Opt.progress
    progress = progressbar('IRIS model.kalman progress');
end

isSolution = true(1,nAlt);

for iLoop = 1 : nLoop
    
    % Next data
    %-----------    
    % Measurement and exogenous variables, and initial observations of
    % measurement variables. Deterministic trends will be subtracted later on.
    s.y1 = Inp(1:ny,:,min(iLoop,end));
    s.g = Inp(ny+1:end,:,min(iLoop,end));
    
    % Add pre-sample initial condition.
    s.y1 = [nan(ny,1),s.y1];
    s.g = [nan(ng,1),s.g];
    
    % Next model solution
    %---------------------
    if iLoop <= nAlt
        T = This.solution{1}(:,:,iLoop);
        R = This.solution{2}(:,:,iLoop);
        s.Z = This.solution{4}(:,:,iLoop);
        s.H = This.solution{5}(:,:,iLoop);
        s.U = This.solution{7}(:,:,iLoop);
        s.ixRequired = This.icondix(1,:,iLoop);
        s.nunit = mynunit(This,iLoop);
        s.Tf = T(1:nf,:);
        s.Ta = T(nf+1:end,:);
        % Keep forward expansion for computing the effect of tunes on shock
        % means. Cut off the expansion within subfunctions.
        s.Rf = R(1:nf,:);
        s.Ra = R(nf+1:end,:);
        s.Zt = s.Z.';
        if Opt.deviation
            s.ka = [];
            s.kf = [];
            s.d = [];
        else
            s.d = This.solution{6}(:,:,iLoop);
            k = This.solution{3}(:,1,iLoop);
            s.kf = k(1:nf,:);
            s.ka = k(nf+1:end,:);
        end
        
        % Store `Expand` matrices only if there are tunes on mean of shocks.
        if ~s.istune
            s.Expand = [];
        else
            s.Expand = cell(size(This.Expand));
            for i = 1 : numel(s.Expand)
                s.Expand{i} = This.Expand{i}(:,:,min(iLoop,end));
            end
        end
        
        % Time-varying stdcorr
        %----------------------
        % Combine currently assigned `stdcorr` in the model object with the
        % user-supplied time-vaying `stdcorr`.
        stdcorri = This.stdcorr(1,:,iLoop).';
        s.stdcorr = modelobj.mycombinestdcorr(stdcorri,Opt.stdcorr,nPer-1);

        % Add presample, which will be used to initialise the Kalman
        % filter.
        s.stdcorr = [stdcorri,s.stdcorr];
        
        % Create covariance matrix from stdcorr vector.
        s.Omg = covfun.stdcorr2cov(s.stdcorr,ne);
        
        % Create reduced form covariance matrices `Sa` and `Sy`, and find
        % measurement variables with infinite measurement shocks, `syinf`.
        s = xxOmg2SaSy(s);
        
        % Free memory.
        s.stdcorr = [];
    end
    
    % Continue immediately if solution is not available; report NaN solutions
    % post mortem.
    isSolution(iLoop) = all(~isnan(T(:)));
    if ~isSolution(iLoop)
        continue
    end
    
    % Deterministic trends
    %----------------------
    % y(t) - D(t) - X(t)*delta = Z*a(t) + H*e(t).
    if nPOut > 0 || Opt.dtrends
        [s.D,s.X] = mydtrends4lik(This,s.ttrend,Opt.outoflik,s.g,iLoop);
    else
        s.D = [];
        s.X = zeros(ny,0,nPer);
    end
    % Subtract fixed deterministic trends from measurement variables
    if ~isempty(s.D)
        s.y1 = s.y1 - s.D;
    end

    % Initial distribution
    %----------------------
    s = kalman.init(s,iLoop,Opt);
    
    % Next tunes on the means of the shocks
    %---------------------------------------
    % Add the effect of the tunes to the constant vector; recompute the
    % effect whenever the tunes have changed or the model solution has changed
    % or both.
    %
    % The std dev of the tuned shocks remain unchanged and hence the
    % filtered shocks can differ from its tunes (unless the user specifies zero
    % std dev).
    if s.istune
        s.tune = tune(:,:,min(iLoop,end));
        [s.d,s.ka,s.kf] = xxShockTunes(s,Opt);
    end
    
    % Make measurement variables with `Inf` measurement shocks look like
    % missing. The `Inf` measurement shocks are detected in `xxomg2sasy`.
    s.y1(s.syinf) = NaN;
    
    % Index of available observations.
    s.yindex = ~isnan(s.y1);
    s.lastObs = max(0,find(any(s.yindex,1),1,'last'));
    s.jyeq = [false,all(s.yindex(:,2:end) == s.yindex(:,1:end-1),1)];
    
    % Number of initial conditions to be optimised
    %----------------------------------------------
    s.ninit = 0;
    if isequal(Opt.initcond,'optimal')
        % All initial conditions, including stationary variables, will be
        % optimised.
        s.ninit = nb;
    elseif isequal(Opt.initmeanunit,'optimal')
        % Estimate fixed initial conditions for unit root processes if the
        % user did not supply data on `'initMeanUnit='` and there is at
        % least one non-stationary measurement variable with at least one
        % observation.
        z = s.Z(any(s.yindex,2),1:s.nunit);
        if any(any(abs(z) > realSmall))
            s.ninit = s.nunit;
        else
            s.ninit = 0;
        end
    end

    % Prediction step
    %-----------------
    % Prepare the struct `s2` for non-linear simulations in this round of
    % prediction steps.
    if s.isnonlin
        s2.iLoop = iLoop;
        if iLoop <= nAlt
            s2 = myprepsimulate(This,s2,iLoop);
        end
    end
    % Run prediction error decomposition and evaluate user-requested
    % objective function.
    [Obj(iLoop),s] = kalman.ped(s,s2,Opt);
    
    % Return immediately if only the object
    if s.isObjOnly
        continue
    end
    
    % Prediction errors uncorrected to estimated init cond and dtrends; these
    % are needed for contributions.
    if s.retCont
        s.peUnc = s.pe;
    end
    
    % Correct prediction errors for estimated initial conditions and dtrends
    % parameters.
    if s.ninit > 0 || nPOut > 0
        est = [s.delta;s.init];
        if s.storePredict
            [s.pe,s.a0,s.y0,s.ydelta] = ...
                kalman.correct(s,s.pe,s.a0,s.y0,est,s.d);
        else
            s.pe = kalman.correct(s,s.pe,[],[],est,[]);
        end
    end
    
    % Calculate prediction steps for fwl variables.
    if s.retPred || s.retSmooth
        s.isxfmse = s.retPredStd || s.retPredMse ...
            || s.retSmoothStd || s.retSmoothMse;
        % Predictions for forward-looking transtion variables have been already
        % filled in in non-linear predictions.
        if ~s.isnonlin
            s = xxPredXfMean(s);
        end
    end
    
    % Add k-step-ahead predictions.
    if s.ahead > 1 && s.storePredict
        s = xxAhead(s);
    end
    
    % Updating step
    %---------------    
    if s.retFilter
        if s.retFilterStd || s.retFilterMse
            s = xxFilterMse(s);
        end
        s = xxFilterMean(s);
    end
    
    % Smoother
    %----------
    % Run smoother for all variables.
    if s.retSmooth
        if s.retSmoothStd || s.retSmoothMse
            s = xxSmoothMse(s);
        end    
        s = xxSmoothMean(s);
    end
    
    % Contributions of measurement variables
    %----------------------------------------
    if s.retCont
        s = kalman.cont(s);
    end
    
    % Return requested data
    %-----------------------
    % Columns in `pe` to be filled.
    if s.ahead > 1
        predCols = 1 : s.ahead;
    else
        predCols = iLoop;
    end

    % Populate hdata output arguments.
    if s.retPred
        doRetPred();
    end
    if s.retFilter
        doRetFilter();
    end
    s.SampleCov = NaN;
    if s.retSmooth
        doRetSmooth();
    end
    
    % Populate regular (non-hdata) output arguments.
    RegOutp.F(:,:,:,iLoop) = s.F*s.V;
    RegOutp.Pe(:,:,predCols) = permute(s.pe,[1,3,4,2]);
    RegOutp.V(iLoop) = s.V;
    RegOutp.Delta(:,iLoop) = s.delta;
    RegOutp.PDelta(:,:,iLoop) = s.PDelta*s.V;
    RegOutp.SampleCov(:,:,iLoop) = s.SampleCov;
    
    % Update progress bar
    %---------------------
    if Opt.progress
        update(progress,iLoop/nLoop);
    end
    
end

if ~all(isSolution)
    utils.warning('model', ...
        'Solution(s) not available:%s.', ...
        sprintf(' #%g',find(~isSolution)));
end


% Nested functions...


%**************************************************************************
    function doRequestOutp()
        s.retPredMean = isfield(HData,'predmean');
        s.retPredMse = isfield(HData,'predmse');
        s.retPredStd = isfield(HData,'predstd');
        s.retPredCont = isfield(HData,'predcont');
        s.retFilterMean = isfield(HData,'filtermean');
        s.retFilterMse = isfield(HData,'filertmse');
        s.retFilterStd = isfield(HData,'filterstd');
        s.retFilterCont = isfield(HData,'filtercont');
        s.retSmoothMean = isfield(HData,'smoothmean');
        s.retSmoothMse = isfield(HData,'smoothmse');
        s.retSmoothStd = isfield(HData,'smoothstd');
        s.retSmoothCont = isfield(HData,'smoothcont');
        s.retPred = s.retPredMean || s.retPredStd || s.retPredMse;
        s.retFilter = s.retFilterMean || s.retFilterStd || s.retFilterMse;
        s.retSmooth = s.retSmoothMean || s.retSmoothStd || s.retSmoothMse;
        s.retCont = s.retPredCont || s.retFilterCont || s.retSmoothCont;
        s.storePredict = s.ahead > 1 ...
            || s.retPred || s.retFilter || s.retSmooth;
    end % doRequestOutp()


%**************************************************************************
    function doRetPred()
        % Return pred mean.
        % Note that s.y0, s.f0 and s.a0 include k-sted-ahead predictions if
        % ahead > 1.
        if s.retPredMean
            yy = permute(s.y0,[1,3,4,2]);
            % Convert `alpha` predictions to `xb` predictions. The
            % `a0` may contain k-step-ahead predictions in 3rd dimension.
            bb = permute(s.a0,[1,3,4,2]);
            for ii = 1 : size(bb,3)
                bb(:,:,ii) = s.U*bb(:,:,ii);
            end
            ff = permute(s.f0,[1,3,4,2]);
            xx = [ff;bb];
            % Shock predictions are always zeros.
            ee = zeros(ne,nPer,s.ahead);
            % Set predictions for the pre-sample period to `NaN`.
            yy(:,1,:) = NaN;
            xx(:,1,:) = NaN;
            ee(:,1,:) = NaN;
            % Add fixed deterministic trends back to measurement vars.
            if ~isempty(s.D)
                % We need to use `bsxfun` to get s.D expanded along 3rd dimension if
                % `ahead=` is greater than 1. This is equivalent to the older version:
                %     yy = yy + s.D(:,:,ones(1,ahead));
                yy = bsxfun(@plus,yy,s.D);
            end
            % Add shock tunes to shocks.
            if s.istune
                % This line is equivalent to the older version:
                %     ee = ee + s.tune(:,:,ones(1,ahead));
                ee = bsxfun(@plus,ee,s.tune);
            end
            % Do not use lags in the prediction output data.
            hdataassign(HData.predmean,This,predCols,yy,xx,ee);
        end
        
        % Return pred std.
        if s.retPredStd
            % Do not use lags in the prediction output data.
            hdataassign(HData.predstd,This,iLoop, ...
                s.Dy0*s.V, ...
                [s.Df0;s.Db0]*s.V, ...
                s.De0*s.V);
        end
        
        % Return prediction MSE for xb.
        if s.retPredMse
            HData.predmse(:,:,:,iLoop) = s.Pb0*s.V;
        end

        % Return PE contributions to prediction step.
        if s.retPredCont
            yy = s.yc0;
            yy = permute(yy,[1,3,2,4]);
            xx = [s.fc0;s.bc0];
            xx = permute(xx,[1,3,2,4]);
            xx(:,1,:) = NaN;
            ee = s.ec0;
            ee = permute(ee,[1,3,2,4]);
            hdataassign(HData.predcont,This,':',yy,xx,ee);
        end

    end % doRetPred()


%**************************************************************************
    function doRetFilter()
        
        if s.retFilterMean
            yy = s.y1;
            xx = [s.f1;s.b1];
            ee = s.e1;
            % Add fixed deterministic trends back to measurement vars.
            if ~isempty(s.D)
                yy = yy + s.D;
            end
            % Add shock tunes to shocks.
            if s.istune
                ee = ee + s.tune;
            end
            % Do not use lags in the filter output data.
            hdataassign(HData.filtermean,This,iLoop,yy,xx,ee);
        end
        
        % Return PE contributions to filter step.
        if s.retFilterCont
            yy = s.yc1;
            yy = permute(yy,[1,3,2,4]);
            xx = [s.fc1;s.bc1];
            xx = permute(xx,[1,3,2,4]);
            ee = s.ec1;
            ee = permute(ee,[1,3,2,4]);
            hdataassign(HData.filtercont,This,':',yy,xx,ee);
        end
        
        % Return filter std.
        if s.retFilterStd
            hdataassign(HData.filterstd,This,iLoop, ...
                s.Dy1*s.V,[s.Df1;s.Db1]*s.V,[]);
        end
        
        % Return filtered MSE for `xb`.
        if s.retFilterMse
            %s.Pb1(:,:,1) = NaN;
            HData.smoothmse(:,:,:,iLoop) = s.Pb2*s.V;
        end
        
    end % doRetFilter()


%**************************************************************************
    function doRetSmooth()
        
        if s.retSmoothMean
            yy = s.y2;
            xx = [s.f2;s.b2(:,:,1)];
            yy(:,1:s.lastSmooth) = NaN;
            xx(:,1:s.lastSmooth-1) = NaN;
            xx(1:nf,s.lastSmooth) = NaN;
            % Add deterministic trends to measurement vars.
            if ~isempty(s.D)
                yy = yy + s.D;
            end
            ee = s.e2;
            ee(:,1:s.lastSmooth) = NaN;
            % Add shock tunes to shocks.
            if s.istune
                ee = ee + s.tune;
            end
            hdataassign(HData.smoothmean,This,iLoop,yy,xx,ee);
        end
        
        % Return smooth std.
        if s.retSmoothStd
            s.Dy2(:,1:s.lastSmooth) = NaN;
            s.Df2(:,1:s.lastSmooth) = NaN;
            s.Db2(:,1:s.lastSmooth-1) = NaN;
            hdataassign(HData.smoothstd,This,iLoop, ...
                s.Dy2*s.V,[s.Df2;s.Db2]*s.V,[]);
        end
        
        % Return PE contributions to smooth step.
        if s.retSmoothCont
            yy = s.yc2;
            yy = permute(yy,[1,3,2,4]);
            xx = [s.fc2;s.bc2];
            xx = permute(xx,[1,3,2,4]);
            ee = s.ec2;
            ee = permute(ee,[1,3,2,4]);
            hdataassign(HData.smoothcont,This,':',yy,xx,ee);
        end
        
        objRange = s.objrange & any(s.yindex,1);
        s.SampleCov = ee(:,objRange)*ee(:,objRange).'/sum(objRange);
        
        % Return smooth MSE for `xb`.
        if s.retSmoothMse
            s.Pb2(:,:,1:s.lastSmooth-1) = NaN;
            HData.smoothmse(:,:,:,iLoop) = s.Pb2*s.V;
        end
        
    end % doRetSmooth()


%**************************************************************************
    function doPrepareNonlin()
        s2.simulateOpt = passvalopt('model.simulate',Opt.simulate{:});
        s2 = simulate.antunantfunc(s2,s2.simulateOpt.anticipate);
        s2.isNonlin = true;
        s2.qAnchors = false(nEqtn,Opt.nonlinearise);
        s2.qAnchors(This.nonlin,:) = true;
        s2.yAnchors = [];
        s2.xAnchors = [];
        s2.eaanchors = [];
        s2.euanchors = [];
        s2.weightsA = [];
        s2.weightsU = [];
        s2.npernonlin = Opt.nonlinearise;
        s2.tplusk = s2.npernonlin - 1;
        s2.progress = [];
        s2.a0 = [];
        s2.e = zeros(ne,1);
        s2.ytune = [];
        s2.xtune = [];
        s2.W = [];
        s2.zerothSegment = 0;
        s2.nLoop = nLoop;
        s2.xxlog = This.log(real(This.solutionid{2}));
        s2.segment = 1;
    end % doPrepareNonlin()


end

% Subfunctions...

%**************************************************************************
function S = xxAhead(S)
% xxAhead  K-step ahead predictions and prediction errors for K>2 when
% requested by caller. This function must be called after correction for
% diffuse initial conditions and/or out-of-lik params has been made.

a0 = permute(S.a0,[1,3,4,2]);
pe = permute(S.pe,[1,3,4,2]);
y0 = permute(S.y0,[1,3,4,2]);
ydelta = permute(S.ydelta,[1,3,4,2]);

% Expand existing prediction vectors.
a0 = cat(3,a0,nan([size(a0),S.ahead-1]));
pe = cat(3,pe,nan([size(pe),S.ahead-1]));
y0 = cat(3,y0,nan([size(y0),S.ahead-1]));
if S.retPred
    % `f0` exists and its k-step-ahead predictions need to be calculated only
    % if `pred` data are requested.
    f0 = permute(S.f0,[1,3,4,2]);
    f0 = cat(3,f0,nan([size(f0),S.ahead-1]));
end

nPer = size(S.y1,2);
for k = 2 : min(S.ahead,nPer-1)
    t = 1+k : nPer;
    repeat = ones(1,numel(t));
    a0(:,t,k) = S.Ta*a0(:,t-1,k-1);
    if ~isempty(S.ka)
        if ~S.istune
            a0(:,t,k) = a0(:,t,k) + S.ka(:,repeat);
        else
            a0(:,1,t,k) = a0(:,t,k) + S.ka(:,t);
        end
    end
    y0(:,t,k) = S.Z*a0(:,t,k);
    if ~isempty(S.d)
        if ~S.istune
            y0(:,t,k) = y0(:,t,k) + S.d(:,repeat);
        else
            y0(:,t,k) = y0(:,t,k) + S.d(:,t);
        end
    end
    if S.retPred
        f0(:,t,k) = S.Tf*a0(:,t-1,k-1);
        if ~isempty(S.kf)
            if ~S.istune
                f0(:,t,k) = f0(:,t,k) + S.kf(:,repeat);
            else
                f0(:,t,k) = f0(:,t,k) + S.kf(:,t);
            end
        end
    end
end
if S.npout > 0
    y0(:,:,2:end) = y0(:,:,2:end) + ydelta(:,:,ones(1,S.ahead-1));
end
pe(:,:,2:end) = S.y1(:,:,ones(1,S.ahead-1)) - y0(:,:,2:end);

S.a0 = ipermute(a0,[1,3,4,2]);
S.pe = ipermute(pe,[1,3,4,2]);
S.y0 = ipermute(y0,[1,3,4,2]);
S.ydelta = ipermute(ydelta,[1,3,4,2]);
if S.retPred
    S.f0 = ipermute(f0,[1,3,4,2]);
end

end % xxAhead()


%**************************************************************************
function S = xxPredXfMean(S)
% xxPredXfMean  Point prediction step for fwl transition variables. The
% MSE matrices are computed in `xxSmoothMse` only when needed.

nf = size(S.Tf,1);
nPer = size(S.y1,2);

% Pre-allocate state vectors.
if nf == 0
    return
end

for t = 2 : nPer
    % Prediction step.
    jy1 = S.yindex(:,t-1);
    S.f0(:,1,t) = S.Tf*(S.a0(:,1,t-1) + S.K1(:,jy1,t-1)*S.pe(jy1,1,t-1,1));
    if ~isempty(S.kf)
        S.f0(:,1,t) = S.f0(:,1,t) + S.kf(:,min(t,end));
    end
end

end % xxPredXfMean()


%**************************************************************************
function S = xxFilterMean(S)

nb = size(S.Ta,1);
nf = size(S.Tf,1);
ne = size(S.Ra,2);
nPer = size(S.y1,2);
yInx = S.yindex;
lastObs = S.lastObs;

% Pre-allocation. Re-use first page of prediction data. Prediction data
% can have multiple pages if `ahead` > 1.
S.b1 = nan(nb,nPer);
S.f1 = nan(nf,nPer);
S.e1 = nan(ne,nPer);
% Note that `S.y1` already exists.

S.e1(:,2:end) = 0;
if lastObs < nPer
    S.b1(:,lastObs+1:end) = S.U*permute(S.a0(:,1,lastObs+1:end,1),[1,3,4,2]);
    S.f1(:,lastObs+1:end) = S.f0(:,1,lastObs+1:end,1);
    S.y1(:,lastObs+1:end) = ipermute(S.y0(:,1,lastObs+1:end,1),[1,3,4,2]);
end

for t = lastObs : -1 : 2
    j = yInx(:,t);
    [y1,f1,b1,e1] = kalman.onestepbackmean(S,t,S.pe(:,1,t,1),S.a0(:,1,t,1), ...
        S.f0(:,1,t,1),S.ydelta(:,1,t),S.d(:,min(t,end)),0);    
    S.y1(~j,t) = y1(~j,1);
    if nf > 0
        S.f1(:,t) = f1;
    end
    S.b1(:,t) = b1;
    S.e1(:,t) = e1;
end

end % xxFilterMean()


%**************************************************************************
function S = xxFilterMse(S)
% xxFilterMse  MSE matrices for updating step.

ny = size(S.Z,1);
nf = size(S.Tf,1);
nb = size(S.Ta,1);
nPer = size(S.y1,2);
lastObs = S.lastObs;

% Pre-allocation.
if S.retSmoothMse
    S.Pb1 = nan(nb,nb,nPer);
end
S.Db1 = nan(nb,nPer); % Diagonal of Pb2.
S.Df1 = nan(nf,nPer); % Diagonal of Pf2.
S.Dy1 = nan(ny,nPer); % Diagonal of Py2.

if lastObs < nPer
    S.Pb1(:,:,lastObs+1:nPer) = S.Pb0(:,:,lastObs+1:nPer);
    S.Dy1(:,lastObs+1:nPer) = S.Dy0(:,lastObs+1:nPer);
    S.Df1(:,lastObs+1:nPer) = S.Df0(:,lastObs+1:nPer);
    S.Db1(:,lastObs+1:nPer) = S.Db0(:,lastObs+1:nPer);
end

for t = lastObs : -1 : 2
    [Pb1,Dy1,Df1,Db1] = xxOneStepBackMse(S,t,0);
    if S.retSmoothMse
        S.Pb1(:,:,t) = Pb1;
    end
    S.Dy1(:,t) = Dy1;
    if nf > 0 && t > 1
        S.Df1(:,t) = Df1;
    end
    S.Db1(:,t) = Db1;
end

end % xxFilterMse()


%**************************************************************************
function S = xxSmoothMse(S)
% xxSmoothMse  Smoother for MSE matrices of all variables.

ny = size(S.Z,1);
nf = size(S.Tf,1);
nb = size(S.Ta,1);
nPer = size(S.y1,2);
lastSmooth = S.lastSmooth;
lastObs = S.lastObs;

% Pre-allocation.
if S.retSmoothMse
    S.Pb2 = nan(nb,nb,nPer);
end
S.Db2 = nan(nb,nPer); % Diagonal of Pb2.
S.Df2 = nan(nf,nPer); % Diagonal of Pf2.
S.Dy2 = nan(ny,nPer); % Diagonal of Py2.

if lastObs < nPer
    S.Pb2(:,:,lastObs+1:nPer) = S.Pb0(:,:,lastObs+1:nPer);
    S.Dy2(:,lastObs+1:nPer) = S.Dy0(:,lastObs+1:nPer);
    S.Df2(:,lastObs+1:nPer) = S.Df0(:,lastObs+1:nPer);
    S.Db2(:,lastObs+1:nPer) = S.Db0(:,lastObs+1:nPer);
end

N = 0;
for t = lastObs : -1 : lastSmooth
    [Pb2,Dy2,Df2,Db2,N] = xxOneStepBackMse(S,t,N);
    if S.retSmoothMse
        S.Pb2(:,:,t) = Pb2;
    end
    S.Dy2(:,t) = Dy2;
    if nf > 0 && t > lastSmooth
        S.Df2(:,t) = Df2;
    end
    S.Db2(:,t) = Db2;
end

end % xxSmoothMse()


%**************************************************************************
function S = xxSmoothMean(S)
% xxSmoothMean  Kalman smoother for point estimates of all variables.

nb = size(S.Ta,1);
nf = size(S.Tf,1);
ne = size(S.Ra,2);
nPer = size(S.y1,2);
lastObs = S.lastObs;
lastSmooth = S.lastSmooth;

% Pre-allocation. Re-use first page of prediction data. Prediction data
% can have multiple pages if ahead > 1.
S.b2 = S.U*permute(S.a0(:,1,:,1),[1,3,4,2]);
S.f2 = permute(S.f0(:,1,:,1),[1,3,4,2]);
S.e2 = zeros(ne,nPer);
S.y2 = S.y1(:,:,1);
% No need to run the smoother beyond last observation.
S.y2(:,lastObs+1:end) = permute(S.y0(:,1,lastObs+1:end,1),[1,3,4,2]);
r = zeros(nb,1);
for t = lastObs : -1 : lastSmooth
    j = S.yindex(:,t);
    [y2,f2,b2,e2,r] = kalman.onestepbackmean(S,t,S.pe(:,1,t,1),S.a0(:,1,t,1), ...
        S.f0(:,1,t,1),S.ydelta(:,1,t),S.d(:,min(t,end)),r);
    S.y2(~j,t) = y2(~j,1);
    if nf > 0
        S.f2(:,t) = f2;
    end
    S.b2(:,t) = b2;
    S.e2(:,t) = e2;
end

end % xxSmoothMean()


%**************************************************************************
function [D,Ka,Kf] = xxShockTunes(S,Opt)
% xxShockTunes  Add tunes on shock means to constant terms.

ne = size(S.Ra,2);
if ne == 0
    return
end

ny = size(S.Z,1);
nf = size(S.Tf,1);
nb = size(S.Ta,1);
nPer = size(S.y1,2);

if Opt.deviation
    D = zeros(ny,nPer);
    Ka = zeros(nb,nPer);
    Kf = zeros(nf,nPer);
else
    D = S.d(:,ones(1,nPer));
    Ka = S.ka(:,ones(1,nPer));
    Kf = S.kf(:,ones(1,nPer));
end

eu = real(S.tune);
ea = imag(S.tune);
eu(isnan(eu)) = 0;
ea(isnan(ea)) = 0;

lastAnt = utils.findlast(ea);
lastUnant = utils.findlast(eu);
last = max(lastAnt,lastUnant);
if isempty(last) || last < 2
    return
end

if lastAnt > 0
    R = model.myexpand(S.R,[],lastAnt,S.Expand{:});
    Rf = R(1:nf,:);
    Ra = R(nf+1:end,:);
else
    Rf = S.Rf;
    Ra = S.Ra;
end
H = S.H;

for t = 2 : last
    ee = [eu(:,t) + ea(:,t),ea(:,t+1:lastAnt)];
    k = size(ee,2);
    D(:,t) = D(:,t) + H*ee(:,1);
    Kf(:,t) = Kf(:,t) + Rf(:,1:ne*k)*ee(:);
    Ka(:,t) = Ka(:,t) + Ra(:,1:ne*k)*ee(:);
end

end % xxShockTunes()


%**************************************************************************
function S = xxOmg2SaSy(S)

% Convert the structural covariance matrix `Omg` to reduced-form
% covariance matrices `Sa` and `Sy`. Detect `Inf` std deviations and remove
% the corresponding observations.

ny = size(S.Z,1);
nf = size(S.Tf,1);
nb = size(S.Ta,1);
ne = size(S.Ra,2);
nPer = size(S.y1,2);
lastOmg = size(S.Omg,3);
tShocks = S.tshocks;
mShocks = S.mshocks;

% Periods where Omg(t) is the same as Omg(t-1).
omgEqual = [false,all(S.stdcorr(:,1:end-1) == S.stdcorr(:,2:end),1)];

% Cut off forward expansion.
Ra = S.Ra(:,1:ne);
Rf = S.Rf(:,1:ne);
Ra = Ra(:,tShocks);
Rf = Rf(:,tShocks);

H = S.H(:,mShocks);
Ht = S.H(:,mShocks).';

S.Sa = nan(nb,nb,lastOmg);
S.Sf = nan(nf,nf,lastOmg);
S.Sfa = nan(nf,nb,lastOmg);
S.Sy = nan(ny,ny,lastOmg);
S.syinf = false(ny,lastOmg);

for t = 1 : lastOmg
    % If Omg(t) is the same as Omg(t-1), do not compute anything and
    % only copy the previous results.
    if omgEqual(t)
        S.Sa(:,:,t) = S.Sa(:,:,t-1);
        S.Sf(:,:,t) = S.Sf(:,:,t-1);
        S.Sfa(:,:,t) = S.Sfa(:,:,t-1);
        S.Sy(:,:,t) = S.Sy(:,:,t-1);
        S.syinf(:,t) = S.syinf(:,t-1);
        continue
    end
    Omg = S.Omg(:,:,t);
    OmgT = Omg(tShocks,tShocks);
    OmgM = Omg(mShocks,mShocks);
    S.Sa(:,:,t) = Ra*OmgT*Ra.';
    S.Sf(:,:,t) = Rf*OmgT*Rf.';
    S.Sfa(:,:,t) = Rf*OmgT*Ra.';
    omgMInf = isinf(diag(OmgM));
    if ~any(omgMInf)
        % No `Inf` std devs.
        S.Sy(:,:,t) = H*OmgM*Ht;
    else
        % Some std devs are `Inf`, we will remove the corresponding observations.
        S.Sy(:,:,t) = ...
            H(:,~omgMInf)*OmgM(~omgMInf,~omgMInf)*Ht(~omgMInf,:);
        S.syinf(:,t) = diag(H(:,omgMInf)*Ht(omgMInf,:)) ~= 0;
    end
end

% Expand `syinf` in 2nd dimension to match the number of periods. This
% is because we use `syinf` to remove observations from `y1` on the whole
% filter range.
if lastOmg < nPer
    S.syinf(:,end+1:nPer) = S.syinf(:,ones(1,nPer-lastOmg));
end

end % xxOmg2SaSy()


%**************************************************************************
function [Pb2,Dy2,Df2,Db2,N] = xxOneStepBackMse(S,T,N)
% xxOneStepBackMse  One-step backward smoothing for MSE matrices.

ny = size(S.Z,1);
nf = size(S.Tf,1);
lastSmooth = S.lastSmooth;
j = S.yindex(:,T);
U = S.U;

if isempty(N) || all(N(:) == 0)
    N = (S.Z(j,:).'/S.F(j,j,T))*S.Z(j,:);
else
    N = (S.Z(j,:).'/S.F(j,j,T))*S.Z(j,:) + S.L(:,:,T).'*N*S.L(:,:,T);
end

Pa0NPa0 = S.Pa0(:,:,T)*N*S.Pa0(:,:,T);
Pa2 = S.Pa0(:,:,T) - Pa0NPa0;
Pa2 = (Pa2 + Pa2.')/2;
Pb2 = kalman.pa2pb(U,Pa2);
Db2 = diag(Pb2);

if nf > 0 && T > lastSmooth
    % Fwl transition variables.
    Pf2 = S.Pf0(:,:,T) - S.Pfa0(:,:,T)*N*S.Pfa0(:,:,T).';
    % Pfa2 = s.Pfa0(:,:,t) - Pfa0N*s.Pa0(:,:,t);
    Pf2 = (Pf2 + Pf2.')/2;
    Df2 = diag(Pf2);
else
    Df2 = nan(nf,1);
end

if ny > 0
    % Measurement variables.
    Py2 = S.F(:,:,T) - S.Z*Pa0NPa0*S.Z.';
    Py2 = (Py2 + Py2.')/2;
    Py2(j,:) = 0;
    Py2(:,j) = 0;
    Dy2 = diag(Py2);
end

end % xxOneStepBackMse()

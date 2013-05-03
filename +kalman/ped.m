function [Obj,S] = ped(S,S2,Opt)
% ped  [Not a public function] Prediction error decomposition and evaluation of objective function.
%
% Backed IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

ny = size(S.Z,1);
nb = size(S.Ta,1);
nf = size(S.Tf,1);
ne = size(S.Ra,2);
nPer = size(S.y1,2);
lastOmg = size(S.Omg,3);

nPOut = S.npout;
nInit = S.ninit;

y1 = S.y1;
Ta = S.Ta;
Tat = S.Ta.';
Tf = S.Tf;
ka = S.ka;
d = S.d;
jy = false(ny,1);
Z = S.Z(jy,:);
X = S.X;

K0 = zeros(nb,0);
K1 = zeros(nb,0);
pe = zeros(0,1);
ZP = zeros(0,nb);

% Initialise objective function components.
sumpeFipe = 0;
sumlogdetF = 0;
% Effect of outofliks and fixed init states on a(t).
Q1 = zeros(nb,nPOut);
Q2 = eye(nb,nInit);
% Effect of outofliks and fixed init states on pe(t).
M1 = zeros(0,nPOut);
M2 = zeros(0,nInit);

% Initialise flags.
isPout = nPOut > 0;
isInit = nInit > 0;
isEst = isPout || isInit;
objRange = S.objrange;

% Initialise sum terms used in out-of-lik estimation.
if isEst
    sumMtFiM = 0;
    sumMtFipe = 0;
else
    sumMtFiM = [];
    sumMtFipe = [];
end

% Initialise matrices that are to be stored.
if ~S.isObjOnly

    % `pe` is allocated as an ny-by-1-by-nPer array because we re-use the same
    % algorithm for both regular runs of the filter and the contributions.
    S.pe = nan(ny,1,nPer);
    
    S.F = nan(ny,ny,nPer);
    S.Fd = nan(1,nPer);
    S.M = nan(ny,nPOut+nInit,nPer);
    
    if S.storePredict
        
        % `a0`, `y0`, `ydelta` are allocated as an ny-by-1-by-nPer array because we
        % re-use the same algorithm for both regular runs of the filter and the
        % contributions.
        S.a0 = nan(nb,1,nPer);
        S.a0(:,1,1) = S.ainit;
        S.y0 = nan(ny,1,nPer);
        S.ydelta = zeros(ny,1,nPer);
        S.f0 = nan(nf,1,nPer);
        
        S.Pa0 = nan(nb,nb,nPer);
        S.Pa1 = nan(nb,nb,nPer);
        S.Pa0(:,:,1) = S.Painit;
        S.Pa1(:,:,1) = S.Painit;
        S.De0 = nan(ne,nPer);
        % Kalman gain matrices.
        S.K0 = nan(nb,ny,nPer);
        S.K1 = nan(nb,ny,nPer);
        S.Q = zeros(nb,nPOut+nInit,nPer);
        S.Q(:,nPOut+1:end,1) = Q2;
        if S.retSmooth
            S.L = nan(nb,nb,nPer);
            S.L(:,:,1) = Ta;
        end
    end
    if S.retFilter || S.retSmooth
        S.Pf0 = nan(nf,nf,nPer);
        S.Pfa0 = nan(nf,nb,nPer);
    end
    if S.retPredStd || S.retFilterStd || S.retSmoothStd ...
            || S.retFilterMse || S.retSmoothMse
        S.Pb0 = nan(nb,nb,nPer);
        S.Dy0 = nan(ny,nPer);
        S.Df0 = nan(nf,nPer);
        S.Db0 = nan(nb,nPer);
    end
    if S.retCont
        S.MtFi = nan(nPOut+nInit,ny,nPer);
    end
end

% Reset initial condition.
a = S.ainit;
P = S.Painit;

% Number of actually observed data points.
nObs = 0;

% Main loop
%-----------
for t = 2 : nPer
    
    % Effect of out-of-liks on `a(t)`
    %---------------------------------
    % Effect of outofliks on `a(t)`. This step must be made before
    % updating `jy` because we use `Ta(t-1)` and `K0(t-1)`.
    if isPout
        Q1 = Ta*Q1 - K0*M1(jy,:);
    end
    
    % Effect of fixed init states on `a(t)`. This step must be made
    % before updating `jy` because we use `Ta(t-1)` and `K0(t-1)`.
    if isInit
        Q2 = Ta*Q2 - K0*M2(jy,:);
    end
    
    % Prediction step t|t-1 for the alpha vector
    %--------------------------------------------
    % Mean prediction `a(t|t-1)`.
    if ~S.isnonlin
        % Prediction `a(t|t-1)` based on `a(t-1|t-2)`, prediction error `pe(t-1)`,
        % the transition matrix `Ta(t-1)`, and the Kalman gain `K0(t-1)`.
        a = Ta*a + K0*pe;
        % Adjust the prediction step for the constant vector.
        if ~isempty(ka)
            if ~S.istune
                a = a + ka;
            else
                a = a + ka(:,t);
            end
        end
    else
        % Run non-linear simulation to produce the mean prediction.
        doNonlinPredict();
    end

    % Reduced-form shock covariance at time t.
    tOmg = min(t,lastOmg);
    Omg = S.Omg(:,:,tOmg);
    Sa = S.Sa(:,:,tOmg);
    Sy = S.Sy(:,:,tOmg);
    
    % MSE P(t|t-1) based on P(t-1|t-2), the predictive Kalman gain `K0(t-1)`, and
    % and the reduced-form covariance matrix Sa(t). Make sure P is numerically
    % symmetric and does not explode over time.
    P = (Ta*P - K0*ZP)*Tat + Sa;
    P = (P + P.')/2;
    
    % Prediction step t|t-1 for measurement variables
    %-------------------------------------------------
    % Index of observations available at time t, `jy`, and index of
    % conditioning observables available at time t, `cy`.
    jy = S.yindex(:,t);
    cy = jy & Opt.condition;
    isCondition = any(cy);
    
    % Z matrix at time t.
    Z = S.Z(jy,:);
    ZP = Z*P;
    PZt = ZP.';
    
    % Mean prediction for observables available, y0(t|t-1).
    y0 = Z*a;
    if ~isempty(d)
        td = min(t,size(d,2));
        y0 = y0 + d(jy,td);
    end
    
    % Prediction MSE, `F(t|t-1)`, for observables available at time t; the size
    % of `F` changes over time.
    F = Z*PZt + Sy(jy,jy);
    
    % Prediction errors for the observables available, `pe(t)`. The size of
    % `pe` changes over time.
    pe = y1(jy,t) - y0;
    
    % Kalman gain matrices.
    K1 = PZt/F; % Gain in the updating step.
    K0 = Ta*K1; % Gain in the next prediction step.
    
    % Effect of out-of-liks on `-pe(t)`
    %-----------------------------------
    if isEst
        M1 = S.Z*Q1 + X(:,:,t);
        M2 = S.Z*Q2;
        M = [M1,M2];
    end
    
    % Likelihood components
    %-----------------------
    if objRange(t)
        % The following variables may change in `doCond`, but we need to store the
        % original values in `doStorePed`.
        pex = pe;
        Fx = F;
        xy = jy;
        if isEst
            Mx = M(xy,:);
        end
        
        if isCondition
            % Condition the prediction step.
            doCondition();
        end
        
        if isEst
            Mxt = Mx.';
            if Opt.objfunc == 1
                MtFi = Mxt/Fx;
            elseif Opt.objfunc == 2
                W = Opt.weighting(xy,xy);
                MtFi = Mxt*W;
            else
                MtFi = 0;
            end
            sumMtFipe = sumMtFipe + MtFi*pex;
            sumMtFiM = sumMtFiM + MtFi*Mx;
        end
        
        % Compute components of the objective function if this period is included
        % in the user specified objective range.
        nObs = nObs + sum(double(xy));
        if Opt.objfunc == 1
            % Likelihood function.
            sumpeFipe = sumpeFipe + (pex.'/Fx)*pex;
            sumlogdetF = sumlogdetF + log(det(Fx));
        elseif Opt.objfunc == 2
            % Weighted sum of prediction errors.
            W = Opt.weighting(xy,xy);
            sumpeFipe = sumpeFipe + pex.'*W*pex;
        end
    end
    
    if ~S.isObjOnly
        % Store prediction error decomposition.
        doStorePed();
    end
    
end % End of main for-loop.

% Evaluate common variance scalar, out-of-lik parameters, fixed init
% conditions, and concentrated likelihood function.
[Obj,V,est,Pest] = ...
    kalman.oolik(sumlogdetF,sumpeFipe,sumMtFiM,sumMtFipe,nObs,Opt);

% Store estimates of out-of-lik parameters, `delta`, cov matrix of
% estimates of out-of-lik parameters, `Pdelta`, fixed init conditions,
% `init`, and common variance scalar, `V`.
S.delta = est(1:nPOut,:);
S.PDelta = Pest(1:nPOut,1:nPOut);
S.init = est(nPOut+1:end,:);
S.V = V;

if ~S.isObjOnly && S.retCont
    S.sumMtFiM = sumMtFiM;
end

% Free memory.
S.Sa = [];
S.Sy = [];

% Nested functions.

%**************************************************************************
    function doStorePed()
        % doStorePed  Store predicition error decomposition.
        S.F(jy,jy,t) = F;
        S.pe(jy,1,t) = pe;
        if isEst
            S.M(:,:,t) = M;
        end
        if S.storePredict
            doStorePredict();
        end
    end % doStorePed().

%**************************************************************************
    function doStorePredict()
        % doStorePredict  Store prediction and updating steps.
        S.a0(:,1,t) = a;
        S.Pa0(:,:,t) = P;
        S.Pa1(:,:,t) = P - K1*ZP;
        S.De0(:,t) = diag(Omg);
        % Compute mean and MSE for all measurement variables, not only
        % for the currently observed ones when predict data are returned.
        S.y0(:,1,t) = S.Z*a;
        if ~isempty(d)
            S.y0(:,1,t) = S.y0(:,1,t) + d(:,td);
        end
        S.F(:,:,t) = S.Z*P*S.Z.' + Sy;
        S.K0(:,jy,t) = K0;
        S.K1(:,jy,t) = K1;
        S.Q(:,:,t) = [Q1,Q2];
        if S.retSmooth
            S.L(:,:,t) = Ta - K0*Z;
        end
        % Predict fwl variables.
        TfPa1 = Tf*S.Pa1(:,:,t-1);
        Pf0 = TfPa1*Tf.' + S.Sf(:,:,min(t,end));
        Pf0 = (Pf0 + Pf0.')/2;
        if S.retFilter || S.retSmooth
            S.Pf0(:,:,t) = Pf0;
            Pfa0 = TfPa1*Ta.' + S.Sfa(:,:,min(t,end));
            S.Pfa0(:,:,t) = Pfa0;
        end
        if S.retPredStd || S.retFilterStd || S.retSmoothStd ...
                || S.retFilterMse || S.retSmoothMse
            S.Pb0(:,:,t) = kalman.pa2pb(S.U,P);
            S.Dy0(:,t) = diag(S.F(:,:,t));
            if nf > 0
                S.Df0(:,t) = diag(Pf0);
            end
            S.Db0(:,t) = diag(S.Pb0(:,:,t));
        end
        if isEst && S.retCont
            S.MtFi(:,xy,t) = MtFi;
        end
    end % doStorePredict().

%**************************************************************************
    function doNonlinPredict()
        % doNonlinPredict  Make non-linear predictions.
        a1 = a + K1*pe;
        S2.a0 = a1;
        S2.zerothSegment = t - 2;
        S2 = simulate.nonlinear(S2,S2.simulateOpt);
        a = S2.w(nf+1:end,1);
        % Store prediction for forward-looking transition variables.
        S.f0(:,1,t) = S2.w(1:nf,1);
    end % doNonlinPredict().

%**************************************************************************
    function doCondition()
        % doCondition  Condition time t predictions upon time t outcomes of
        % conditioning measurement variables.
        Zc = S.Z(cy,:);
        y0c = Zc*a;
        if ~isempty(d)
            y0c = y0c + d(cy,td);
        end
        pec = y1(cy,t) - y0c;
        Fc = Zc*P*Zc.' + Sy(cy,cy);
        Kc = (Zc*P).' / Fc;
        ac = a + Kc*pec;
        Pc = P - Kc*Zc*P;
        Pc = (Pc + Pc.')/2;
        % Index of available non-condition observations.
        xy = jy & ~cy;
        if any(xy)
            Zx = S.Z(xy,:);
            y0x = Zx*ac;
            if ~isempty(d)
                y0x = y0x + d(xy,td);
            end
            pex = y1(xy,t) - y0x;
            Fx = Zx*Pc*Zx.' + Sy(xy,xy);
            if isEst
                ZZ = Zx - Zx*Kc*Zc;
                M1x = ZZ*Q1 + X(xy,:,t);
                M2x = ZZ*Q2;
                Mx = [M1x,M2x];
            end
        else
            pex = zeros(0,1);
            Fx = zeros(0);
            if isEst
                Mx = zeros(0,nPOut+nInit);
            end
        end
    end % doCondition().

end
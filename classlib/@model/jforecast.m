function Outp = jforecast(This,Inp,Range,varargin)
% jforecast  Forecast with judgmental adjustments (conditional forecasts).
%
% Syntax
% =======
%
%     F = jforecast(M,D,Range,...)
%
% Input arguments
% ================
%
% * `M` [ model ] - Solved model object.
%
% * `D` [ struct ] - Input data from which the initial condition is taken.
%
% * `Range` [ numeric ] - Forecast range.
%
% Output arguments
% =================
%
% * `F` [ struct ] - Output struct with the judgmentally adjusted forecast.
%
% Options
% ========
%
% * `'anticipate='` [ *`true`* | `false` ] - If true, real future shocks are
% anticipated, imaginary are unanticipated; vice versa if false.
%
% * `'currentOnly='` [ *`true`* | `false` ] - If true, MSE matrices will be
% computed only for current-dated variables, not for their lags or leads.
%
% * `'deviation='` [ `true` | *`false`* ] - Treat input and output data as
% deviations from balanced-growth path.
%
% * `'dtrends='` [ *`'auto'`* | `true` | `false` ] - Measurement data contain
% deterministic trends.
%
% * `'initCond='` [ *`'data'`* | `'fixed'` ] - Use the MSE for the initial
% conditions if found in the input data or treat the initical conditions as
% fixed.
%
% * `'meanOnly='` [ `true` | *`false`* ] - Return only mean data, i.e. point
% estimates.
%
% * `'plan='` [ plan ] - Simulation plan specifying the exogenised variables
% and endogenised shocks.
%
% * `'vary='` [ struct | *empty* ] - Database with time-varying std
% deviations or cross-correlations of shocks.
%
% Description
% ============
%
% When adjusting the mean and/or std devs of shocks, you can use real and
% imaginary numbers ot distinguish between anticipated and unanticipated
% shocks:
%
% * any shock entered as an imaginary number is treated as an
% anticipated change in the mean of the shock distribution;
%
% * any std dev of a shock entered as an imaginary number indicates that
% the shock will be treated as anticipated when conditioning the forecast
% on the reduced-form tunes.
%
% * the same shock or its std dev can have both the real and the imaginary
% part.
%
% Description
% ============
%
% Example
% ========
%
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

pp = inputParser();
pp.addRequired('M',@ismodel);
pp.addRequired('Inp',@(x) isstruct(x) || iscell(x));
pp.addRequired('Range',@isnumeric);
pp.parse(This,Inp,Range);
Range = Range(1) : Range(end);

if ~isempty(varargin) && ~ischar(varargin{1})
    cond = varargin{1};
    varargin(1) = [];
    isCond = true;
else
    cond = [];
    isCond = false;
end

opt = passvalopt('model.jforecast',varargin{:});

isPlanCond = isa(opt.plan,'plan') && ~isempty(opt.plan,'cond');
isCond = isCond || isPlanCond;

if isequal(opt.dtrends,'auto')
    opt.dtrends = ~opt.deviation;
end

% Tunes.
isSwap = isplan(opt.plan) && ~isempty(opt.plan,'tunes');

% Create real and imag `stdcorr` vectors from user-supplied databases.
[opt.stdcorrreal,opt.stdcorrimag] = mytune2stdcorr(This,Range,cond,opt);

% TODO: Remove 'missing', 'contributions' options from jforecast,
% 'anticipate' scalar.

%--------------------------------------------------------------------------

ny = size(This.solution{4},1);
nx = size(This.solution{1},1);
nb = size(This.solution{7},1);
nf = nx - nb;
ne = size(This.solution{2},2);
nAlt = size(This.Assign,3);
nPer = length(Range);
xRange = Range(1)-1 : Range(end);
nXPer = length(xRange);

% Current-dated variables in the original state vector.
if opt.currentonly
    xCurrInx = imag(This.solutionid{2}) == 0;
else
    xCurrInx = true(size(This.solutionid{2}));
end
nXCurr = sum(xCurrInx);
fCurri = xCurrInx(1:nf);
bCurri = xCurrInx(nf+1:end);

% Get initial condition for the alpha vector. The `datarequest` function
% always expands the `alpha` vector to match `nalt`. The `ainitmse` and
% `xinitmse` matrices can be empty.
[aInit,xInit,nanInit,aInitMse,xInitMse] = ...
    datarequest('init',This,Inp,Range);

% Check for availability of all initial conditions.
doChkInitCond();
nInit = size(aInit,3);
nInitMse = size(aInitMse,4);

% Get input data for y, current dates of [xf;xb], and e. The size of all
% data is equalised in 3rd dimensin in the `datarequest` function.
[yInp,xInp,eInp] = datarequest('y,x,e',This,Inp,Range);
nData = size(xInp,3);

% Get exogenous variables in dtrend equations.
if opt.dtrends
    G = datarequest('g',This,Inp,Range);
end

% Determine the total number of cycles.
nLoop = max([nAlt,nInit,nInitMse,nData]);

lastOrZeroFunc = @(x) max([0,find(any(x,1),1,'last')]);
vecFunc = @(x) x(:);

if isSwap || isPlanCond
    [ya,xa,ea,ua,Ya,Xa] = myanchors(This,opt.plan,Range);
end

if isSwap
    % Load positions (anchors) of exogenised and endogenised data points.
    if ~opt.anticipate
        [ea,ua] = deal(ua,ea);
    end
    xa = xa(xCurrInx,:);
    % Check for NaNs in exogenised variables, and check the number of
    % exogenised and endogenised data points.
    doChkExogenised();
    lastEa = lastOrZeroFunc(ea);
    lastUa = lastOrZeroFunc(ua);
    lastYa = lastOrZeroFunc(ya); %#ok<NASGU>
    lastXa = lastOrZeroFunc(xa); %#ok<NASGU>
else
    lastEa = 0;
    lastUa = 0;
    lastYa = 0; %#ok<NASGU>
    lastXa = 0; %#ok<NASGU>
end

if isCond
    % Load conditioning data.
    if isPlanCond
        Y = yInp;
        X = xInp;
        E = zeros(ne,nPer);
        Xa = Xa(xCurrInx,:);
        X = X(xCurrInx,:,:);
    else
        Y = datarequest('y',This,cond,Range);
        X = datarequest('x',This,cond,Range);
        E = datarequest('e',This,cond,Range);
        Y = Y(:,:,1);
        X = X(:,:,1);
        E = E(:,:,1);
        X = X(xCurrInx,:);
        Ya = ~isnan(Y);
        Xa = ~isnan(X);
    end
    lastYa = lastOrZeroFunc(Ya);
    lastXa = lastOrZeroFunc(Xa);
    isCond = lastYa > 0 || lastXa > 0;
    % Check for overlaps between shocks from input data and shocks from
    % conditioning data, and add up the overlapping shocks.
    doChkOverlap();
else
    lastYa = 0;
    lastXa = 0;
end

if opt.anticipate
    lastE = lastOrZeroFunc(any(real(eInp) ~= 0,3));
    lastU = lastOrZeroFunc(any(imag(eInp) ~= 0,3));
else
    lastU = lastOrZeroFunc(any(real(eInp) ~= 0,3));
    lastE = lastOrZeroFunc(any(imag(eInp) ~= 0,3));
end

last = max([lastXa,lastYa,lastE,lastEa,lastU,lastUa,lastYa,lastXa]);

if isSwap
    ya = ya(:,1:last);
    xa = xa(:,1:last);
    ea = ea(:,1:last);
    ua = ua(:,1:last);
    % Indices of exogenised data points and endogenised shocks.
    exi = [ya(:).',xa(:).'];
    endi = [false,false(1,nb),ua(:).',ea(:).'];
else
    exi = false(1,(ny+nXCurr)*last);
    endi = false(1,1+nb+2*ne*last);
end

if isCond
    Ya = Ya(:,1:last,:);
    Xa = Xa(:,1:last,:);
    Y = Y(:,1:last,:);
    X = X(:,1:last,:);
    % Index of conditions on measurement and transition variables.
    condi = [Ya(:).',Xa(:).'];
    % Index of conditions on measurement and transition variables excluding
    % exogenised position.
    condiNotExi = condi(~exi);
end

% Index of parameterisation with solutions not available.
[~,nanSol] = isnan(This,'solution');

% Initialise output data.
hData = struct();
hData.mean = hdataobj(This,struct('Precision',opt.precision), ...
    nXPer,nLoop);
if ~opt.meanonly
    hData.std = hdataobj(This, ...
        struct('IsStd',true,'Precision',opt.precision), ...
        nXPer,nLoop);
end

% Main loop
%-----------

if opt.progress
    % Create progress bar.
    progress = progressbar('IRIS model.solve progress');
end

s = struct();
s = simulate.antunantfunc(s,opt.anticipate);

for iloop = 1 : nLoop
    
    if iloop <= nAlt
        % Expansion needed to t+k.
        k = max(1,last) - 1;
        This = expand(This,k);
        Tf = This.solution{1}(1:nf,:,iloop);
        Ta = This.solution{1}(nf+1:end,:,iloop);
        R = This.solution{2}(:,:,iloop);
        Rf = R(1:nf,1:ne);
        Ra = R(nf+1:end,1:ne);
        Kf = This.solution{3}(1:nf,:,iloop);
        Ka = This.solution{3}(nf+1:end,:,iloop);
        Z = This.solution{4}(:,:,iloop);
        H = This.solution{5}(:,:,iloop);
        D = This.solution{6}(:,:,iloop);
        U = This.solution{7}(:,:,iloop);
        Ut = U.';
        % Compute deterministic trends if requested.
        if opt.dtrends
            W = mydtrendsrequest(This,'range',Range,G,iloop);
        end
        % Swapped system.
        if opt.meanonly
            [M,Ma] = myforecastswap(This,iloop,exi,endi,last);
        else
            [M,Ma,N,Na] = myforecastswap(This,iloop,exi,endi,last);
        end
        stdcorre = [];
        stdcorru = [];
        doStdcorr();
    end
    
    % Solution not available.
    if nanSol(min(iloop,end));
        continue
    end
    
    % Initial condition.
    a0 = aInit(:,1,min(iloop,end));
    x0 = xInit(:,1,min(end,iloop));
    if isempty(aInitMse) || isequal(opt.initcond,'fixed')
        Pa0 = zeros(nb);
        Dxinit = zeros(nb,1);
    else
        Pa0 = aInitMse(:,:,1,min(iloop,end));
        Dxinit = diag(xInitMse(:,:,min(iloop,end)));
    end
    
    % Expected and unexpected shocks.
    e = s.antFunc(eInp(:,:,min(end,iloop)));
    u = s.unantFunc(eInp(:,:,min(end,iloop)));
    
    if isSwap
        % Tunes on measurement variables.
        y = yInp(:,1:last,min(end,iloop));
        if opt.dtrends
            y = y - W(:,1:last);
        end
        % Tunes on transition variables.
        x = xInp(:,1:last,min(end,iloop));
        x = x(xCurrInx,:);
    else
        y = nan(ny,last);
        x = nan(nXCurr,last);
    end
    
    % Pre-allocate mean arrays.
    xCurr = nan(nXCurr,nPer);
    
    % Pre-allocate variance arrays.
    if ~opt.meanonly
        Dy = nan(ny,nPer);
        DxCurr = nan(nXCurr,nPer);
        Du = nan(ne,nPer);
        De = nan(ne,nPer);
    end
    
    % Solve the swap system.
    if last > 0
        % inp := [const;a0;u;e].
        inp = [+(~opt.deviation);a0(:); ...
            vecFunc(u(:,1:last));vecFunc(e(:,1:last))];
        % outp := [y;x].
        outp = [y(:);x(:)];
        
        % Swap exogenised outputs and endogenised inputs.
        % rhs := [inp(~endi);outp(exi)].
        % lhs := [outp(~exi);inp(endi)].
        rhs = [inp(~endi);outp(exi)];
        lhs = M*rhs;
        a = Ma*rhs;
        
        if ~opt.meanonly || isCond
            % Prhs is the MSE/Cov matrix of the RHS.
            Prhs = zeros(1+nb+2*ne*last);
            Prhs(1+(1:nb),1+(1:nb)) = Pa0;
            Pu = covfun.stdcorr2cov(stdcorru(:,1:last),ne);
            Pe = covfun.stdcorr2cov(stdcorre(:,1:last),ne);
            inx = 1+nb+(1:ne);
            for i = 1 : last
                Prhs(inx,inx) = Pu(:,:,i);
                inx = inx + ne;
            end
            for i = 1 : last
                Prhs(inx,inx) = Pe(:,:,i);
                inx = inx + ne;
            end
            Prhs = Prhs(~endi,~endi);
            % Add zeros for the std errors of exogenised data points.
            if any(exi)
                Prhs = blkdiag(Prhs,zeros(sum(exi)));
            end
        end

        if ~opt.meanonly
            % Plhs is the cov matrix of the LHS.
            Plhs = N*Prhs*N.';
            Pa = Na*Prhs*Na.';
            Plhs = (Plhs+Plhs.')/2;
            Pa = (Pa+Pa.')/2;
        end
        
        if isCond
            Yd = Y(:,:,min(end,iloop));
            Yd(~Ya) = NaN;
            if opt.dtrends
                Yd = Yd - W(:,1:last);
            end
            Xd = X(:,:,min(end,iloop));
            Xd(~Xa) = NaN;
            outp = [Yd(:);Xd(:)];
            z = M(condiNotExi,:);
            % Prediction error.
            pe = outp(condi) - lhs(condiNotExi);
            % Update mean forecast.
            upd = simulate.updatemean(z,Prhs,pe);
            rhs = rhs + upd;
            lhs = lhs + M*upd;
            a = a + Ma*upd;
            if ~opt.meanonly
                % Update forecast MSE.
                z = N(condiNotExi,:);
                upd = simulate.updatemse(z,Prhs);
                Prhs = Prhs - upd;
                Plhs = Plhs - N*upd*N.';
                Pa = Pa - Na*upd*Na.';
                Prhs = (Prhs+Prhs.')/2;
                Plhs = (Plhs+Plhs.')/2;
                Pa = (Pa+Pa.')/2;
            end
        end
        
        doLhsrhs2Yxuea();
        
    else
        u = zeros(ne,last);
        e = zeros(ne,last);
        a = a0;
        if ~opt.meanonly
            Pa = Pa0;
        end
    end
    
    % Forecast between `last+1` and `nper`.
    doBeyond();
    
    % Free memory.
    a = [];
    Pa = [];
    
    % Add measurement detereministic trends.
    if opt.dtrends
        y = y + W;
    end
    
    % Store final results.
    doAssignSmooth();
    
    if opt.progress
        % Update progress bar.
        update(progress,iloop/nLoop);
    end
end
% End of main loop.

% Report parameterisation with solutions not available.
doChkNanSol();

% Create output database from hdataobj.
doRetOutp();

% Nested functions.

%**************************************************************************
    function doChkInitCond()
        if ~isempty(nanInit)
            utils.error('model', ...
                'This initial condition is not available: ''%s''.', ...
                nanInit{:});
        end
    end % doChkInitCond().

%**************************************************************************
    function doChkExogenised()
        % Check for NaNs in exogenised variables, and check the number of
        % exogenised and endogenised data points.
        inx1 = [ya;xa];
        inx2 = [any(isnan(yInp),3); ...
            any(isnan(xInp(xCurrInx,:,:)),3)];
        inx = any(inx1 & inx2,2);
        if any(inx)
            yVec = This.solutionvector{1};
            xVec = This.solutionvector{2};
            xVec = xVec(xCurrInx);
            yxVec = [yVec,xVec];
            % Some of the variables are exogenised to NaNs.
            utils.error('model', ...
                'This variable is exogenised to NaN: ''%s''.', ...
                yxVec{inx});
        end
        % Check number of exogenised and endogenised data points.
        if nnzexog(opt.plan) ~= nnzendog(opt.plan)
            utils.warning('model', ...
                ['The number of exogenised data points (%g) does not match ', ...
                'the number of endogenised data points (%g).'], ...
                nnzexog(opt.plan),nnzendog(opt.plan));
        end
    end % doChkExogenised().

%**************************************************************************
    function doChkOverlap()
        if any(E(:) ~= 0)
            if any(eInp(:) ~= 0)
                utils.warning('model', ...
                    ['Both input data and conditioning data include ', ...
                    'structural shocks, and they will be added up together.']);
            end
            eInp = bsxfun(@plus,eInp,E);
        end
    end % doChkOverlap().

%**************************************************************************
    function doLhsrhs2Yxuea()
        outp = zeros((ny+nXCurr)*last,1);
        inp = zeros((ne+ne)*last,1);
        outp(~exi) = lhs(1:sum(~exi));
        outp(exi) = rhs(sum(~endi)+1:end);
        inp(~endi) = rhs(1:sum(~endi));
        inp(endi) = lhs(sum(~exi)+1:end);
        y = reshape(outp(1:ny*last),[ny,last]);
        outp(1:ny*last) = [];
        xCurr(:,1:last) = reshape(outp,[nXCurr,last]);
        outp(1:nXCurr*last) = [];
        
        inp(1) = [];
        x0 = U*inp(1:nb);
        inp(1:nb) = [];
        u = reshape(inp(1:ne*last),[ne,last]);
        inp(1:ne*last) = [];
        e = reshape(inp(1:ne*last),[ne,last]);
        inp(1:ne*last) = [];
        
        if opt.meanonly
            return
        end
        
        Poutp = zeros((ny+nXCurr)*last);
        Pinp = zeros((ne+ne)*last);
        Poutp(~exi,~exi) = Plhs(1:sum(~exi),1:sum(~exi));
        Poutp(exi,exi) = Prhs(sum(~endi)+1:end,sum(~endi)+1:end);
        Pinp(~endi,~endi) = Prhs(1:sum(~endi),1:sum(~endi));
        Pinp(endi,endi) = Plhs(sum(~exi)+1:end,sum(~exi)+1:end);
        
        if ny > 0
            inx = 1 : ny;
            for t = 1 : last
                Dy(:,t) = diag(Poutp(inx,inx));
                inx = inx + ny;
            end
            Poutp(1:ny*last,:) = [];
            Poutp(:,1:ny*last) = [];
        end
        
        inx = 1 : nXCurr;
        for t = 1 : last
            DxCurr(:,t) = diag(Poutp(inx,inx));
            inx = inx + nXCurr;
        end
        % Poutp(1:nxcurr*last,:) = [];
        % Poutp(:,1:nxcurr*last) = [];
        
        Pinp(1,:) = [];
        Pinp(:,1) = [];
        Pxinit = U*Pinp(1:nb,1:nb)*Ut;
        Dxinit = diag(Pxinit);
        Pinp(1:nb,:) = [];
        Pinp(:,1:nb) = [];
        
        if ne > 0
            inx = 1 : ne;
            for t = 1 : last
                Du(:,t) = diag(Pinp(inx,inx));
                inx = inx + ne;
            end
            Pinp(1:ne*last,:) = [];
            Pinp(:,1:ne*last) = [];
            inx = 1 : ne;
            for t = 1 : last
                De(:,t) = diag(Pinp(inx,inx));
                inx = inx + ne;
            end
        end
        % Pinput(1:ne*last,:) = [];
        % Pinput(:,1:ne*last) = [];
    end % doLhsRhs2Yxue().

%**************************************************************************
    function doBeyond()
        % dobeyond  Simulate from last to nper. 
        
        % When expanding the vectors we must use `1:end` and not of just `:` in 1st
        % dimension because of a bug in Matlab causing unexpected behaviour when
        % the original vector is empty.
        xCurr(1:end,last+1:nPer) = 0;
        y(1:end,last+1:nPer) = 0;
        e(1:end,last+1:nPer) = 0;
        u(1:end,last+1:nPer) = 0;        
        Ucurr = U(bCurri,:);
        Tfcurr = Tf(fCurri,:);
        Kfcurr = Kf(fCurri,:);
        for t = last+1 : nPer
            xfcurr = Tfcurr*a;
            a = Ta*a;
            if ~opt.deviation
                xfcurr = xfcurr + Kfcurr;
                a = a + Ka;
            end
            xCurr(:,t) = [xfcurr;Ucurr*a];
            if ny > 0
                y(:,t) = Z*a;
                if ~opt.deviation
                    y(:,t) = y(:,t) + D;
                end
            end
        end
        
        if opt.meanonly
            return
        end
        
        Du(1:end,last+1:nPer) = stdcorru(1:ne,last+1:nPer).^2;
        De(1:end,last+1:nPer) = stdcorre(1:ne,last+1:nPer).^2;
        Tfcurrt = Tfcurr.';
        Tat = Ta.';
        Rfcurr = Rf(fCurri,:);
        Rfcurrt = Rfcurr.';
        Rat = Ra.';
        Ht = H.';
        Ucurrt = Ucurr.';
        Zt = Z.';
        for t = last+1 : nPer
            Pue = covfun.stdcorr2cov(stdcorru(:,t),ne) ...
                + covfun.stdcorr2cov(stdcorre(:,t),ne);
            Pxfcurr = Tfcurr*Pa*Tfcurrt + Rfcurr*Pue*Rfcurrt;
            Pa = Ta*Pa*Tat + Ra*Pue*Rat;
            Pxbcurr = Ucurr*Pa*Ucurrt;
            DxCurr(:,t) = [diag(Pxfcurr);diag(Pxbcurr)];
            if ny > 0
                Py = Z*Pa*Zt + H*Pue*Ht;
                Dy(:,t) = diag(Py);
            end
        end
    end % doBeyond().

%**************************************************************************
    function doChkNanSol()
        % Report parameterisations with solutions not available.
        if any(nanSol)
            utils.warning('model', ...
                ['No solution available, no forecast computed ', ...
                'for this parameterisation: #%g.'], ...
                num2cell(find(nanSol)));
        end
    end % doChkNanSol().

%**************************************************************************
    function doStdcorr()
        % TODO: use `mycombinestdcorr` here.
        % Combine `stdcorr` from the current parameterisation and the
        % `stdcorr` supplied through the tune database.
        stdcorre = This.stdcorr(1,:,iloop).';
        stdcorre = stdcorre(:,ones(1,nPer));
        stdcorrixreal = ~isnan(opt.stdcorrreal);
        if any(stdcorrixreal(:))
            stdcorre(stdcorrixreal) = ...
                opt.stdcorrreal(stdcorrixreal);
        end
        
        stdcorru = This.stdcorr(1,:,iloop).';
        stdcorru = stdcorru(:,ones(1,nPer));
        stdcorriximag = ~isnan(opt.stdcorrimag);
        if any(stdcorriximag(:))
            stdcorru(stdcorriximag) = ...
                opt.stdcorrimag(stdcorriximag);
        end
        
        % Set the std devs of the endogenised shocks to zero. Otherwise an
        % anticipated endogenised shock would have a non-zero unanticipated
        % std dev, and vice versa.
        if isSwap
            tempstd = stdcorre(1:ne,1:last);
            tempstd(ea) = 0;
            tempstd(ua) = 0;
            stdcorre(1:ne,1:last) = tempstd;
            tempstd = stdcorru(1:ne,1:last);
            tempstd(ea) = 0;
            tempstd(ua) = 0;
            stdcorru(1:ne,1:last) = tempstd;
        end
        
        if ~opt.anticipate
            [stdcorru,stdcorre] = deal(stdcorre,stdcorru);
        end
    end % doStdcorr().

%**************************************************************************
    function doAssignSmooth()
        % Final point forecast.
        tempX = nan(nx,nXPer);
        tempX(xCurrInx,2:end) = xCurr;
        tempX(nf+1:end,1) = x0;
        if opt.anticipate
            eu = complex(e,u);
        else
            eu = complex(u,e);
        end
        hdataassign(hData.mean,This,iloop, ...
            [nan(ny,1),y], ...
            tempX, ...
            [nan(ne,1),eu]);
        % Final std forecast.
        if ~opt.meanonly
            Dx = nan(nx,nPer);
            Dx(xCurrInx,:) = DxCurr;            
            if opt.anticipate
                Deu = complex(De,Du);
            else
                Deu = complex(Du,De);
            end
            hdataassign(hData.std,This,iloop, ...
                [nan(ny,1),Dy], ...
                [[nan(nf,1);Dxinit],Dx], ...
                [nan(ne,1),Deu]);
        end
    end % doAssignSmooth().

%**************************************************************************
    function doRetOutp()
        Outp = struct();
        if opt.meanonly
            Outp = hdata2tseries(hData.mean,This,xRange);
        else
            Outp.mean = hdata2tseries(hData.mean,This,xRange);
            Outp.std = hdata2tseries(hData.std,This,xRange);
        end
    end % doRetOutp().

end
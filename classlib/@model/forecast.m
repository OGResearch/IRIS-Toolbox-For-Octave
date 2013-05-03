function [func,fcon,Pi] = forecast(m,init,range,varargin)
% forecast  Compute unconditional and conditional forecasts.
%
% Syntax
% =======
%
%     f1 = forecast(m,d,range)
%     [f1,f2] = forecast(m,d,range,[],...)
%     [f1,f2] = forecast(m,d,range,j,...)
%
% Input arguments
% ================
%
% * `m` [ model ] - Solved model object.
%
% * `d` [ struct ] - Input data from which the initial condition is taken.
%
% * `range` [ numeric ] - Forecast range.
%
% * `j` [ struct ] - Conditioning database or database with judgmental
% adjustments, i.e. structural conditions on the mean and std devs of
% shocks, and reduced-form conditions on measurement variables.
%
% Output arguments
% =================
%
% * `f1` [ struct ] - Output struct with forecast data including structural
% tunes.
%
% * `f2` [ struct ] - Output struct with forecast data including both
% structural and reduced-form tunes.
%
% Options
% ========
%
% * `'anticipate='` [ *`true`* | `false` ] - If true, real future shocks are
% anticipated, imaginary are unanticipated; vice versa if false.
%
% * `'deviation='` [ `true` | *`false`* ] - Treat input and output data as
% deviations from balanced-growth path.
%
% * `'dtrends='` [ *'auto'* | `true` | `false` ] - Measurement data contain
% deterministic trends.
%
% * `'initCond='` [ *'data'* | 'fixed' ] - Use the MSE for the initial
% conditions if found in the input data or treat the initical conditions as
% fixed.
%
% * `'meanOnly='` [ `true` | *`false`* ] - Return only mean data, i.e. point
% estimates.
%
% * `'output='` [ *'auto'* | 'dbase' | 'dpack' ] - Format of output data.
%
% Description
% ============
%
% The structural tunes, i.e. tunes on the mean of some of the shocks, can
% be entered either throught the initial condition database, `d`, or the
% conditioning database, `j`, but not both.
%
% Example
% ========
%
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

% Old syntax for conditioning database.
tune = [];
if ~isempty(varargin) && (isstruct(varargin{1}) || isempty(varargin{1}))
    tune = varargin{1};
    varargin(1) = [];
end

opt = passvalopt('model.forecast',varargin{:});

% Merge stddev tunes found in the tunes database and in options.std.
if ~isempty(tune) && ~isempty(opt.std)
    utils.error('model', ...
        'Cannot combine a tune database and the ''std='' option.');
elseif ~isempty(opt.std)
    tune = opt.std;
end

% Determine format of input and output data.
output = 'dbase';

if ischar(opt.dtrends)
    opt.dtrends = ~opt.deviation;
end

%**************************************************************************

ny = size(m.solution{4},1);
nx = size(m.solution{1},1);
nb = size(m.solution{7},1);
nf = nx - nb;
ne = size(m.solution{2},2);
nalt = size(m.Assign,3);
range = range(1) : range(end);
nper = length(range);

nanticipate = length(opt.anticipate(:));
ndeviation = length(opt.deviation(:));
ndtrends = length(opt.dtrends(:));

% Get init cond (mean, MSE) for alpha vector.
% Initmse is [] if MSE is not available.
[ainitmean,xinitmean,naninit,ainitmse,xinitmse] = ...
    datarequest('init',m,init,range); %#ok<NASGU,ASGLU>
if ~isempty(naninit)
    utils.error('model', ...
        'This initial condition is not available: ''%s''.', ...
        naninit{:});
end

% Exogenous variables in dtrend equations.
G = datarequest('g',m,init,range);

ninit = size(ainitmean,3);

% Get structural conditions.

% Structural conditions can be entered either through the initial condition
% database or tune database, but not both.

if ~isempty(init)
    shock1 = datarequest('e',m,init,range);
    nshock1 = size(shock1,3);
    isshock1 = any(shock1(:) ~= 0);
else
    isshock1 = false;
end

if ~isempty(tune)
    shock2 = datarequest('e',m,tune,range);
    nshock2 = size(shock2,3);
    isshock2 = any(shock2(:) ~= 0);
else
    isshock2 = false;
end

if isshock1 && isshock2
    % Shock tunes supplied simultaneously in input database and in
    % tune database are not allowed.
    utils.error('model', ...
        ['Cannot combine shock tunes through both', ...
        'the input database and a tune database.']);
elseif isshock1
    shock = shock1;
    nshock = nshock1;
elseif isshock2
    shock = shock2;
    nshock = nshock2;
else
    nshock = 1;
    shock = [];
end

% Get user-supplied variances of shocks.
opt.stdcorr = mytune2stdcorr(m,range,tune,opt);

% Get reduced-form conditions.
if ~isempty(tune)
    cond = datarequest('y',m,tune,range);
    ncond = size(cond,3);
else
    cond = nan([ny,nper]);
    ncond = 1;
end

% Total number of cycles.
nloop = max([nalt,nanticipate,ndeviation,ndtrends,ninit,ncond,nshock]);

% Pre-allocate output datapack.
func = struct();
func.mean_ = { ...
    nan([ny,1+nper,nloop]), ...
    nan([nx,1+nper,nloop]), ...
    nan([ne,1+nper,nloop]), ...
    [range(1)-1,range], ...
    };
if ~opt.meanonly
    func.mse_ = { ...
        nan([ny,ny,1+nper,nloop]), ...
        nan([nx,nx,1+nper,nloop]), ...
        nan([ne,ne,1+nper,nloop]), ...
        [range(1)-1,range], ...
        };
end
if nargout > 1
    fcon = func;
end

Pi = nan([1,nloop]); % test statistic

% Index of underdetermined systems.
underdetetermined = false([1,nloop]);
% Index of NaN solutions.
nansolution = false([1,nloop]);

use = struct();

for iloop = 1 : nloop
    
    if iloop <= ndeviation
        use.deviation = opt.deviation(iloop);
    end
    
    if iloop <= ndtrends
        use.dtrends = opt.dtrends(iloop);
    end
    
    if iloop <= nanticipate
        use.anticipate = opt.anticipate(iloop);
    end
    
    if iloop <= ncond
        % measurement conditions including detereministic trends
        use.conddet = cond(:,:,iloop);
        use.condindex = ~isnan(use.conddet);
        use.lastcond = max([0,find(any(use.condindex,1),1,'last')]); % last imposed tune
        use.condindex = use.condindex(:,1:use.lastcond);
        use.condindex = use.condindex(:)';
    end
    
    if iloop <= nalt
        % model solution
        [use.T,use.R,use.K,use.Z,use.H,use.D,use.U,use.Omega] = ...
            mysspace(m,iloop,true);
        % matrices for forward expansion
        use.Expand = cell(size(m.Expand));
        for i = 1 : length(m.Expand)
            use.Expand{i} = m.Expand{i}(:,:,iloop);
        end
        % deterministic trends
        if opt.dtrends
            use.W = mydtrendsrequest(m,'range',range,G,iloop);
        end
    end
    
    if any(any(isnan(use.T)))
        nansolution(iloop) = true;
        continue
    end
    
    if iloop <= nalt
        % Combine `stdcorr` from the current parameterisation and the
        % `stdcorr` supplied through the tune database.
        use.stdcorr = m.stdcorr(1,:,iloop).';
        use.stdcorr = use.stdcorr(:,ones([1,nper]));
        stdcorrix = ~isnan(opt.stdcorr);
        if any(stdcorrix(:))
            use.stdcorr(stdcorrix) = ...
                opt.stdcorr(stdcorrix);
        end
        % Active shocks are only up to the period of the last condition
        % imposed.
        % TODO: Introduce an option to allow the user to choose the last
        % period where shocks are considered.
        use.activeshocks = use.stdcorr(1:ne,1:use.lastcond) > 0;
        use.activeshocks = transpose(use.activeshocks(:));
    end
    
    if iloop <= nalt || iloop <= ncond
        % conditions adjusted for deterministic trends
        use.cond = use.conddet;
        if use.dtrends
            use.cond = use.cond - use.W;
        end
    end
    
    if iloop <= ninit
        % Init condition for mean and MSE.
        use.initmean = ainitmean(:,1,iloop);
        if ~isempty(ainitmse) && ~strcmpi(opt.initcond,'fixed')
            use.initmse = ainitmse(:,:,iloop);
            use.activeinit = abs(diag(use.initmse)) > 0;
            use.activeinit = use.activeinit.';
        elseif isnumeric(opt.initcond)
            if iloop <= nalt
                error('iris:model', ...
                    'Option ''initcod='' not implemented in `forecast` yet.');
            end
        else
            use.initmse = sparse(zeros(length(use.initmean)));
            use.activeinit = false([1,length(use.initmean)]);
        end
    end
    
    if sum(use.condindex) > sum(use.activeinit) + sum(use.activeshocks)
        underdetetermined(iloop) = true;
        continue
    end
    
    if iloop <= nshock
        if ~isempty(shock)
            use.shock = shock(:,:,iloop);
            % Last imposed shock.
            use.lastshock = max([0,find(any(use.shock ~= 0),1,'last')]);
        else
            use.shock = zeros([ne,nper]);
            use.lastshock = 0;
        end
    end
    
    % Furthest anticipated shock needed.
    if use.anticipate
        use.last = max([use.lastshock,use.lastcond]);
        use.tplusk = use.last;
    else
        use.last = 0;
        use.tplusk = max([0,find(any(imag(use.shock) ~= 0),1,'last')]);
    end
    
    if ne > 0
        % Expansion available up to t+k0.
        if use.tplusk > size(use.R,2)/ne
            [use.R,ans,use.Expand{5}] = ...
                model.myexpand(use.R,[],use.tplusk-1,use.Expand{1:5},[]); %#ok<NOANS,ASGLU>
        end
    end
    
    % Compute multipliers of initial condition, unanticipated and
    % anticipated shocks.
    if use.lastcond > 0
        if iloop <= nalt || iloop <= ncond
            % Multipliers of initial condition and unanticipated shocks.
            % This is needed whether forecast is anticipated or not.
            [use.DyDa0,use.DaDa0,use.DfDa0] = timedom.multiplierinit(...
                use.T,use.R,use.K,use.Z,use.H,use.D,use.U,...
                use.lastcond,use.activeinit);
            [use.DyDeu,use.DaDeu,use.DfDeu] = timedom.multipliereu(...
                use.T,use.R,use.K,use.Z,use.H,use.D,use.U,...
                use.lastcond,use.activeshocks);
            use.DfaDa0eu = [];
            for t = 1 : use.lastcond
                use.DfaDa0eu = [...
                    use.DfaDa0eu;...
                    use.DfDa0((t-1)*nf+(1:nf),:),use.DfDeu((t-1)*nf+(1:nf),:);...
                    use.DaDa0((t-1)*nb+(1:nb),:),use.DaDeu((t-1)*nb+(1:nb),:);...
                    ];
            end
        end
        if iloop <= nalt || iloop <= ncond || iloop <= nanticipate
            if use.anticipate
                % Mutlipliers of anticipated shocks.
                use.DyDea = timedom.multiplierea(...
                    use.T,use.R,use.K,use.Z,use.H,use.D,use.U,...
                    use.lastcond,use.activeshocks);
            end
        end
    end
    
    % Structural conditions.
    
    [y,w] = timedom.simulatemean(...
        use.T,use.R,use.K,use.Z,use.H,use.D,use.U,...
        use.initmean,use.shock,nper,use.anticipate,use.deviation);
    xf = w(1:nf,:);
    a = w(nf+1:end,:);
    Pe = covfun.stdcorr2cov(use.stdcorr,ne);
    [Py,Pfa] = simulatemse_(...
        use.T,use.R,use.K,use.Z,use.H,use.D,use.U,Pe,...
        use.initmse,nper);
    
    % Store forecast with structural conditions.
    
    if use.dtrends
        func.mean_{1}(:,2:end,iloop) = y + use.W;
    else
        func.mean_{1}(:,2:end,iloop) = y;
    end
    func.mean_{2}(:,2:end,iloop) = [xf;a];
    func.mean_{2}(nf+1:end,1,iloop) = use.initmean;
    func.mean_{3}(:,2:end,iloop) = use.shock;
    if ~opt.meanonly
        func.mse_{1}(:,:,2:end,iloop) = Py;
        func.mse_{2}(:,:,2:end,iloop) = Pfa;
        func.mse_{2}(nf+1:end,nf+1:end,1,iloop) = use.initmse;
        func.mse_{3}(:,:,2:end,iloop) = Pe;
    end
    
    % Reduced-form conditions.
    
    if use.lastcond > 0 && nargout > 1
        
        % Conditional mean.
        
        Z1 = use.DyDa0(use.condindex,:);
        if use.anticipate
            Z2 = use.DyDea(use.condindex,:);
        else
            Z2 = use.DyDeu(use.condindex,:);
        end
        pe = use.cond(use.condindex) - y(use.condindex);
        % P = blkdiag([initmse,0;0,diag(varvec)]) = [P1;P2]
        % Z = [Z1,Z2];
        P1 = use.initmse(use.activeinit,use.activeinit);
        if all(all(use.stdcorr(ne+1:end,1:use.lastcond) == 0))
            % All cross-corrs are zero, P2 is diagonal.
            varvec = use.stdcorr(1:ne,1:use.lastcond).^2;
            P2 = sparse(diag(varvec(use.activeshocks)));
        else
            % P2 is block-diagonal.
            temp = covfun.stdcorr2cov(use.stdcorr(:,1:use.lastcond),ne);
            P2 = zeros(ne*use.lastcond);
            index = 1 : ne;
            for t = 1 : use.lastcond
                P2(index,index) = temp(:,:,t);
                index = index + ne;
            end
            P2 = P2(use.activeshocks(:),use.activeshocks(:));
        end
        P_Zt = [ ... % P_Zt = P*transpose(Z);
            P1*transpose(Z1); ...
            P2*transpose(Z2); ...
            ];
        F = [Z1,Z2] * P_Zt;
        M = P_Zt / F;
        tempshock = use.shock(:,1:use.lastcond);
        gamma = [ % gamma := [a(0);e(1);...;e(lastcond)] both active and inactive
            use.initmean
            tempshock(:)
            ];
        active = [use.activeinit,use.activeshocks];
        gammahat = gamma;
        dgammahat = M * pe(:); % only active entries
        gammahat(active) = gammahat(active) + dgammahat;
        
        % Simulate conditional mean with new init cond and new residuals.
        tmpinit = gammahat(1:nb);
        tmpshock = [reshape(gammahat(nb+1:end),[ne,use.lastcond]),use.shock(:,use.lastcond+1:end)];
        [yhat,what] = timedom.simulatemean(...
            use.T,use.R,use.K,use.Z,use.H,use.D,use.U,...
            tmpinit,tmpshock,nper,use.anticipate,use.deviation);
        xfhat = what(1:nf,:);
        ahat = what(nf+1:end,:);
        
        % Store conditional mean.
        
        if opt.deviation
            fcon.mean_{1}(:,2:end,iloop) = yhat;
        else
            fcon.mean_{1}(:,2:end,iloop) = yhat + use.W;
        end
        fcon.mean_{2}(:,2:end,iloop) = [xfhat;ahat];
        fcon.mean_{2}(nf+1:end,1,iloop) = tmpinit;
        fcon.mean_{3}(:,2:end,iloop) = tmpshock;
        
        % Conditional MSE.
        
        if opt.anticipate
            Z2 = use.DyDeu(use.condindex,:);
            % P1 = use.initmse(use.activeinit,use.activeinit);
            % P2 = sparse(diag(use.varvec(use.activeshocks)));
            P_Zt = [
                P1*transpose(Z1); ...
                P2*transpose(Z2); ...
                ];
            F = [Z1,Z2] * P_Zt;
            M = P_Zt / F;
        end
        P = blkdiag(P1,P2);
        V = zeros(nb+ne*use.lastcond); % V = MSE gammahat, i.e. both active and inactive
        V(active,active) = P - M*transpose(P_Zt);
        
        % test statistic
        if nargout > 2
            Pi(iloop) = dgammahat.' * (P\dgammahat);
        end
        
        % MSE for y(t)
        % t = 1 .. lastcond
        X = [use.DyDa0,use.DyDeu];
        Vy = X*V(active,active)*transpose(X);
        
        % MSE for xf(t) and alpha(t)
        % t = 1 .. lastcond
        Vfa = use.DfaDa0eu*V(active,active)*transpose(use.DfaDa0eu);
        
        % MSE for e(t)
        % t = 1 .. lastcond
        Ve = V(nb+1:end,nb+1:end);
        
        % Project MSE.
        % t = lastcond+1 .. nper
        if ~opt.meanonly
            Ve2 = covfun.stdcorr2cov(use.stdcorr(:,use.lastcond+1:end),ne);
            [Vy2,Vfa2] = simulatemse_(...
                use.T,use.R,use.K,use.Z,use.H,use.D,use.U, ...
                Ve2,Vfa(end-nb+1:end,end-nb+1:end),nper-use.lastcond);
        end
        
        % Store conditional MSE.
        
        if ~opt.meanonly
            for t = 1 : use.lastcond
                fcon.mse_{1}(:,:,1+t,iloop) = Vy((t-1)*ny+(1:ny),(t-1)*ny+(1:ny));
                fcon.mse_{2}(:,:,1+t,iloop) = Vfa((t-1)*nx+(1:nx),(t-1)*nx+(1:nx));
                fcon.mse_{3}(:,:,1+t,iloop) = Ve((t-1)*ne+(1:ne),(t-1)*ne+(1:ne));
            end
            fcon.mse_{2}(nf+1:end,nf+1:end,1,iloop) = V(1:nb,1:nb); % initial condition
            fcon.mse_{1}(:,:,1+(use.lastcond+1:nper),iloop) = Vy2;
            fcon.mse_{2}(:,:,1+(use.lastcond+1:nper),iloop) = Vfa2;
            fcon.mse_{3}(:,:,1+(use.lastcond+1:nper),iloop) = Ve2;
        end
        
    else
        
        % No tunes entered but two output arguments requestes. Just copy the
        % func to fcon.
        if nargout > 1
            for i = 1 : 3
                fcon.mean_{i}(:,:,iloop) = func.mean_{i}(:,:,iloop);
                if ~opt.meanonly
                    fcon.mse_{i}(:,:,:,iloop) = func.mse_{i}(:,:,:,iloop);
                end
            end
        end
        
    end
    
end

%**************************************************************************
% Post-mortem.

% Transform `alpha` to `xb`.
func = myalpha2xb(m,func);
if nargout > 1
    fcon = myalpha2xb(m,fcon);
end

% Fix negative diagonal entries.
if ~opt.meanonly
    for i = 1 : 3
        func.mse_{i} = timedom.fixcov(func.mse_{i});
        if nargout > 1
            fcon.mse_{i} = timedom.fixcov(fcon.mse_{i});
        end
    end
end

% Create `var_` datapacks from `mse_` datapacks. This can be done only
% after we have converted `alpha` to `xb`.
if ~opt.meanonly
    func.var_ = model.mymse2var(func.mse_);
    if nargout > 1
        fcon.var_ = model.mymse2var(fcon.mse_);
    end
end

% Convert datapack to database.
if strcmp(output,'dbase')
    if opt.meanonly
        func = dp2db(m,func.mean_);
    else
        func = dp2db(m,func);
    end
    if nargout > 1
        if opt.meanonly
            fcon = dp2db(m,fcon.mean_);
        else
            fcon = dp2db(m,fcon);
        end
    end
end

% Underdetermined conditional forecast system.
if any(underdetetermined)
    utils.warning('model', ...
        ['Underdetermined conditional forecast system; ', ...
        'forecast not computed:%s.'], ...
        sprintf(' #%g',find(underdetermined)));
end

% Expansion not avaiable.
if any(nansolution)
    utils.warning('model', ...
        '#Solution_not_available', ...
        sprintf(' #%g',find(nansolution)));
end

end

%**************************************************************************
% Subfunction simulatemse_().
function [Py,Pfa] = simulatemse_(T,R,K,Z,H,D,U,Pe,initmse,nper)

% Make sure cov matrices are numerically symmetric.
symm = @(X) (X + X')/2;

[nx,nb] = size(T);
[ny,ne] = size(H);
nf = nx - nb;

Py = nan([ny,ny,nper]);
Pfa = nan([nx,nx,nper]);
if size(Pe,3) == 1 && nper > 1
    Pe = Pe(:,:,ones([1,nper]));
end
for t = 1 : nper
    % Pesparse = sparse(Pe(:,:,t));
    Sigmax = symm(R(:,1:ne)*Pe(:,:,t)*R(:,1:ne)');
    Sigmay = symm(H*Pe(:,:,t)*H');
    if t == 1
        if isempty(initmse) || all(all(initmse == 0))
            Pfa(:,:,t) = Sigmax;
        else
            Pfa(:,:,t) = symm(T*initmse*T' + Sigmax);
        end
    else
        Pfa(:,:,t) = symm(T*Pfa(nf+1:end,nf+1:end,t-1)*T' + Sigmax);
    end
    Py(:,:,t) = symm(Z*Pfa(nf+1:end,nf+1:end,t)*Z' + Sigmay);
end

end
% End of subfunction simulatemse_().
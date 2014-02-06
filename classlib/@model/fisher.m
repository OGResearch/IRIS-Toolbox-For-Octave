function [F,FF,Delta,Freq,G,Step] = fisher(This,NPer,PList,varargin)
% fisher  Approximate Fisher information matrix in frequency domain.
%
% Syntax
% =======
%
%     [F,FF,Delta,Freq] = fisher(M,NPer,List,...)
%
% Input arguments
% ================
%
% * `M` [ model ] - Solved model object.
%
% * `NPer` [ numeric ] - Length of the hypothetical range for which the
% Fisher information will be computed.
%
% * `List` [ cellstr ] - List of parameters with respect to which the
% likelihood function will be differentiated.
%
% Output arguments
% =================
%
% * `F` [ numeric ] - Approximation of the Fisher information matrix.
%
% * `FF` [ numeric ] - Contributions of individual frequencies to the total
% Fisher information matrix.
%
% * `Delta` [ numeric ] - Kronecker delta by which the contributions in
% `Fi` need to be multiplied to sum up to `F`.
%
% * `Freq` [ numeric ] - Vector of frequencies at which the Fisher
% information matrix is evaluated.
%
% Options
% ========
%
% * `'chkSstate='` [ `true` | *`false`* | cell ] - Check steady state in
% each iteration; works only in non-linear models.
%
% * `'deviation='` [ *`true`* | `false` ] - Exclude the steady state effect
% at zero frequency.
%
% * `'exclude='` [ char | cellstr | *empty* ] - List of measurement
% variables that will be excluded from the likelihood function.
%
% * `'percent='` [ `true` | *`false`* ] - Report the overall Fisher matrix
% `F` as Hessian w.r.t. the log of variables; the interpretation for this
% is that the Fisher matrix describes the changes in the log-likelihood
% function in reponse to percent, not absolute, changes in parameters.
%
% * `'progress='` [ `true` | *`false`* ] - Display progress bar in the
% command window.
%
% * `'refresh='` [ *`true`* | `false` ] - Refresh dynamic links in each
% differentiation step.
%
% * `'solve='` [ *`true`* | `false` ] - Re-solve model in each differentiation
% step.
%
% * `'sstate='` [ `true` | *`false`* | cell ] - Re-compute steady state in each
% differentiation step; if the model is non-linear, you can pass in a cell
% array with opt used in the `sstate` function.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

% Validate required input arguments.
pp = inputParser();
if ismatlab
pp.addRequired('this',@(x) isa(x,'model'));
pp.addRequired('nper',@(x) isnumeric(x) && length(x) == 1);
pp.addRequired('plist',@(x) iscellstr(x) || ischar(x));
pp.parse(This,NPer,PList);
else
pp = pp.addRequired('this',@(x) isa(x,'model'));
pp = pp.addRequired('nper',@(x) isnumeric(x) && length(x) == 1);
pp = pp.addRequired('plist',@(x) iscellstr(x) || ischar(x));
pp = pp.parse(This,NPer,PList);
end

% Read and validate optional input arguments.
opt = passvalopt('model.fisher',varargin{:});

ny = sum(This.nametype == 1);
nx = size(This.solution{1},1);
nb = size(This.solution{1},2);
nf = nx - nb;
ne = sum(This.nametype == 3);
nAlt = size(This.Assign,3);

% Process the 'exclude' option.
excl = false(ny,1);
if ~isempty(opt.exclude)
    if ischar(opt.exclude)
        opt.exclude = regexp(opt.exclude,'\w+','match');
    end
    ylist = This.name(This.nametype == 1);
    for i = 1 : length(opt.exclude)
        index = strcmp(ylist,opt.exclude{i});
        excl(index) = true;
    end
end

% Get parameter cellstr list from a char list.
if ischar(PList)
    PList = regexp(PList,'\w+','match');
end

% Initialise steady-state solver and chksstate options.
opt.sstate = mysstateopt(This,'silent',opt.sstate);
opt.chksstate = mychksstateopt(This,opt.chksstate);

%--------------------------------------------------------------------------

ny = ny - sum(excl);
if ny == 0
    utils.warning('model', ...
        'No measurement variables included in computing Fisher matrix.');
end

yLog = This.log(This.nametype == 1);
yLog(excl) = [];

[assignPos,stdcorrPos] = mynameposition(This,PList,'error');
assignNan = isnan(assignPos);
stdcorrNan = isnan(stdcorrPos);

pri = struct();
pri.Assign = This.Assign;
pri.stdcorr = This.stdcorr;
pri.assignpos = assignPos;
pri.stdcorrpos = stdcorrPos;

nPList = length(PList);
nFreq = floor(NPer/2) + 1;
Freq = 2*pi*(0 : nFreq-1)/NPer;

% Kronecker delta vector.
% Different for even or odd number of periods.
Delta = ones(1,nFreq);
if mod(NPer,2) == 0
    Delta(2:end-1) = 2;
else
    Delta(2:end) = 2;
end

FF = nan(nPList,nPList,nFreq,nAlt);
F = nan(nPList,nPList,nAlt);

% Create a command-window progress bar.
if opt.progress
    progress = progressbar('IRIS model.fisher progress');
end

throwErr = true;
expandSol = false;

for iAlt = 1 : nAlt    
    % Fetch the i-th parameterisation.
    m = This(iAlt);
    
    % Minimum necessary state space.
    [T0,R0,Z0,H0,Omg0,nunit0] = doGetSspace();
    
    % SGF and inverse SGF at p0.
    [G,Gi] = xxSgfy(T0,R0,Z0,H0,Omg0,nunit0,Freq,opt);
    
    % Compute derivatives of SGF and steady state
    % wrt the selected parameters.
    dG = nan(ny,ny,nFreq,nPList);
    if ~opt.deviation
        dy = zeros(ny,nPList);
    end
    % Determine differentiation step.
    p0 = nan(1,nPList);
    p0(~assignNan) = m.Assign(1,assignPos(~assignNan));
    p0(~stdcorrNan) = m.stdcorr(1,stdcorrPos(~stdcorrNan));
    Step = max([abs(p0);ones(1,nPList)],[],1)*eps()^opt.epspower;
    
    for i = 1 : nPList
        pp = p0;
        pm = p0;
        pp(i) = pp(i) + Step(i);
        pm(i) = pm(i) - Step(i);
        twoSteps = pp(i) - pm(i);

        isSstate = ~opt.deviation && ~isnan(assignPos(i));
        
        % Steady state, state space and SGF at p0(i) + step(i).
        m = myupdatemodel(m,pp,pri,opt,throwErr,expandSol);
        if isSstate
            yp = doGetSstate();
        end
        [Tp,Rp,Zp,Hp,Omgp,nunitp] = doGetSspace();
        Gp = xxSgfy(Tp,Rp,Zp,Hp,Omgp,nunitp,Freq,opt);
        
        % Steady state,state space and SGF at p0(i) - step(i).
        m = myupdatemodel(m,pm,pri,opt,throwErr,expandSol);
        if isSstate
            ym = doGetSstate();
        end
        [Tm,Rm,Zm,Hm,Omgm,nunitm] = doGetSspace();
        Gm = xxSgfy(Tm,Rm,Zm,Hm,Omgm,nunitm,Freq,opt);
        
        % Differentiate SGF and steady state.
        dG(:,:,:,i) = (Gp - Gm) / twoSteps;
        if isSstate
            dy(:,i) = (yp(:) - ym(:)) / twoSteps;
        end
        
        % Reset model parameters to `p0`.
        m.Assign(1,assignPos(~assignNan)) = p0(1,~assignNan);
        m.stdcorr(1,stdcorrPos(~stdcorrNan)) = p0(1,~stdcorrNan);
        
        % Update the progress bar.
        if opt.progress
            update(progress,((iAlt-1)*nPList+i)/(nAlt*nPList));
        end
        
    end
    
    % Compute Fisher information matrix.
    % Steady-state-independent part.
    for i = 1 : nPList
        for j = i : nPList
            fi = zeros(1,nFreq);
            for k = 1 : nFreq
                fi(k) = ...
                    trace(real(Gi(:,:,k)*dG(:,:,k,i)*Gi(:,:,k)*dG(:,:,k,j)));
            end
            if ~opt.deviation
                % Add steady-state effect to zero frequency.
                % We don't divide the effect by 2*pi because
                % we skip dividing G by 2*pi, too.
                A = dy(:,i)*dy(:,j)';
                fi(1) = fi(1) + NPer*trace(Gi(:,:,1)*(A + A'));
            end
            FF(i,j,:,iAlt) = fi;
            FF(j,i,:,iAlt) = fi;
            f = Delta*fi';
            F(i,j,iAlt) = f;
            F(j,i,iAlt) = f;
        end
    end

    if opt.percent
        P0 = diag(p0);
        F(:,:,iAlt) = P0*F(:,:,iAlt)*P0;
    end
    
end
% End of main loop.

FF = FF / 2;
F = F / 2;

% Nested functions.

%**************************************************************************
    function [T,R,Z,H,Omg,nunit] = doGetSspace()
        T = m.solution{1};
        [nx,nb] = size(T);
        nf = nx - nb;
        nunit = mynunit(m,1);
        Z = m.solution{4}(~excl,:);
        T = T(nf+1:end,:);
        % Cut off forward expansion.
        ne = sum(m.nametype == 3);
        R = m.solution{2}(nf+1:end,1:ne);
        H = m.solution{5}(~excl,1:ne);
        Omg = omega(m);
    end % doGetSspace().

%**************************************************************************
    function y = doGetSstate()
        % Get the steady-state levels for the measurement variables.
        y = m.Assign(This.nametype == 1);
        y = real(y);
        % Adjust for the excluded measurement variables.
        y(excl) = [];
        % Take log of log-variables; `ylog` has been already adjusted for the
        % excluded measurement variables.
        y(yLog) = log(y(yLog));
    end % doGetSstate().

end 

% Subfunctions.

%**************************************************************************
function [G,Gi] = xxSgfy(T,R,Z,H,Omg,nunit,freq,opt)
% Spectrum generating function and its inverse.
% Computationally optimised for observables.
[ny,nb] = size(Z);
nfreq = length(freq(:));
Sgm1 = R*Omg*R.';
Sgm2 = H*Omg*H.';
G = nan(ny,ny,nfreq);
for i = 1 : nfreq
    freqi = freq(i);
    if freqi == 0 && nunit > 0
        % Exclude the unit-root part of the transition matrix, and compute SGF only
        % for the stable part. Stationary variables are unaffected.
        Z0 = Z(:,nunit+1:end);
        T0 = T(nunit+1:end,nunit+1:end);
        R0 = R(nunit+1:end,:);
        X = Z0 / (eye(nb-nunit) - T0);
        G(:,:,i) = xxSymmetric(X*(R0*Omg*R0.')*X' + Sgm2);
    else
        X = Z/(eye(nb) - T*exp(-1i*freqi));
        G(:,:,i) = xxSymmetric(X*Sgm1*X' + Sgm2);
    end
    
end
% Do not divide G by 2*pi.
% First, this cancels out in Gi*dG*Gi*dG
% and second, we do not divide the steady-state effect
% by 2*pi either.
if nargout > 1
    Gi = nan(ny,ny,nfreq);
    if opt.chksgf
        for i = 1 : nfreq
            Gi(:,:,i) = xxPInverse(G(:,:,i),opt.tolerance);
        end
    else
        for i = 1 : nfreq
            Gi(:,:,i) = inv(G(:,:,i));
        end
    end
end
end % xxSgfy().

%**************************************************************************
function x = xxSymmetric(x)
% Minimise numerical inaccuracy between upper and lower parts
% of symmetric matrices.
index = eye(size(x)) == 1;
x = (x + x')/2;
x(index) = real(x(index));
end % xxSymmetric().

%**************************************************************************
function X = xxPInverse(A,Tol)
if isempty(A)
    X = zeros(size(A'),class(A));
    return
end
m = size(A,1);
s = svd(A);
r = sum(s/s(1) > Tol);
if r == 0
    X = zeros(size(A'),class(A));
elseif r == m
    X = inv(A);
else
    [U,~,V] = svd(A,0);
    S = diag(1./s(1:r));
    X = V(:,1:r)*S*U(:,1:r)';
end
end % xxPInverse(). = diag(1./s(1:r));
    X = V(:,1:r)*S*U(:,1:r)';
end
end % xxPInverse().
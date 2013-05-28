function [This,NPath,NanDeriv,Sing1] = mysolve(This,IAlt,Opt,ExpMatrices)
% mysolve  [Not a public function] First-order quasi-triangular solution.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

try
    IAlt;
catch %#ok<CTCH>
    IAlt = 1;
end

try
    Opt;
catch %#ok<CTCH>
    Opt = [];
end

try
    ExpMatrices;
catch %#ok<CTCH>
    ExpMatrices = true;
end

%--------------------------------------------------------------------------

if isempty(Opt)
    Opt = struct( ...
        'linear',This.linear, ...
        'progress',false, ...
        'select',true, ...
        'symbolic',true, ...
        'warning',false, ...
        'expand',0);
end

eigValTol = This.Tolerance(1);
realSmall = getrealsmall();

ny = length(This.systemid{1});
nx = length(This.systemid{2});
nb = sum(imag(This.systemid{2}) < 0);
nf = nx - nb;
ne = length(This.systemid{3});
nn = sum(This.nonlin);
fKeep = ~This.metadelete;
nFKeep = sum(fKeep);
nAlt = size(This.Assign,3);

if islogical(IAlt)
    IAlt = find(IAlt);
elseif isequal(IAlt,Inf)
    IAlt = 1 : nAlt;
end

% Pre-allocate solution matrices.
doAllocSolution();

% Set `NPATH` to 1 initially to handle correctly the cases when only a
% subset of parameterisations is solved for.
NPath = ones(1,nAlt);
IAlt = IAlt(:).';

if Opt.progress
    progress = progressbar('IRIS model.solve progress');
end

Sing1 = false(sum(This.eqtntype == 1),nAlt);
NanDeriv = cell(1,nAlt);

for ialt = IAlt
    % Select only the equations in which at least one parameter or steady state
    % has changed since the last differentiation.
    eqSelect = myaffectedeqtn(This,ialt,Opt.select,Opt.linear);
    eqSelect(This.eqtntype >= 3) = false;
    [This,deriv,nanDeriv] = myderiv(This,eqSelect,ialt, ...
        Opt.symbolic,Opt.linear);
    if any(nanDeriv)
        NPath(ialt) = -3;
        NanDeriv{ialt} = nanDeriv;
        continue
    end
    [This,system] = mysystem(This,deriv,eqSelect,ialt);
    % Check system matrices for complex numbers.
    if ~isreal(system.K{1}) ...
            || ~isreal(system.K{2}) ...
            || ~isreal(system.A{1}) ...
            || ~isreal(system.A{2}) ...
            || ~isreal(system.B{1}) ...
            || ~isreal(system.B{2}) ...
            || ~isreal(system.E{1}) ...
            || ~isreal(system.E{2})
        NPath(ialt) = 1i;
        continue;
    end
    % Check system matrices for NaNs.
    if any(isnan(system.K{1})) ...
            || any(isnan(system.K{2})) ...
            || any(any(isnan(system.A{1}))) ...
            || any(any(isnan(system.A{2}))) ...
            || any(any(isnan(system.B{1}))) ...
            || any(any(isnan(system.B{2}))) ...
            || any(any(isnan(system.E{1}))) ...
            || any(any(isnan(system.E{2})))
        NPath(ialt) = NaN;
        continue;
    end
    [SS,TT,QQ,ZZ,This.eigval(1,:,ialt),eqorder] = doSchur();
    if NPath(ialt) == 1
        if ~doSspace()
			if chksstate(This,'warning=',false,'error=',false)==0 && isnan(This)
				NPath(ialt) = -4;
			else
				NPath(ialt) = -1;
			end
        end
    end
    if Opt.progress
        update(progress,ialt/length(IAlt));
    end
end

if Opt.expand > 0
    This = expand(This,Opt.expand);
end

% Nested functions.

%**************************************************************************
    function [SS,TT,QQ,ZZ,EigVal,EqOrder] = doSchur()
        % Ordered real QZ decomposition.
        fA = full(system.A{2});
        fB = full(system.B{2});
        EqOrder = 1 : size(fA,1);
        % If the QZ re-ordering fails, change the order of equations --
        % place the first equation last, and repeat.
        warning('off','MATLAB:ordqz:reorderingFailed');
        while true
            AA = fA(EqOrder,:);
            BB = fB(EqOrder,:);
            [SS,TT,QQ,ZZ] = qz(AA,BB,'real');
            % Ordered inverse eigvals.
            EigVal = -ordeig(SS,TT);
            EigVal = EigVal(:).';
            issevn2 = doSevn2Patch();
            stable = abs(EigVal) >= 1 + eigValTol;
            unit = abs(abs(EigVal)-1) < eigValTol;
            % Clusters of unit, stable, and unstable eigenvalues.
            clusters = zeros(size(EigVal));
            % Unit roots first.
            clusters(unit) = 2;
            % Stable roots second.
            clusters(stable) = 1;
            % Unstable roots last.
            % Re-order by the clusters.
            lastwarn('');
            [SS,TT,QQ,ZZ] = ordqz(SS,TT,QQ,ZZ,clusters);
            isemptywarn = isempty(lastwarn());
            % If the first equations is ordered second, it indicates the
            % next cycle would bring the equations to their original order.
            % We stop and throw an error.
            if isemptywarn || EqOrder(2) == 1
                break
            else
                EqOrder = EqOrder([2:end,1]);
            end
        end
        warning('on','MATLAB:ordqz:reorderingFailed');
        if ~isemptywarn
            utils.error('model', ...
                ['QZ re-ordering failed because ', ...
                'some eigenvalues are too close to swap, and ', ...
                'equation re-ordering does not help.']);
        end
        if Opt.warning && EqOrder(1) ~= 1
            utils.warning('model', ...
                ['Numerical instability in QZ decomposition. ', ...
                'Equations re-ordered %g time(s).'], ...
                EqOrder(1)-1);
        end
        
        % Re-order the inverse eigvals.
        EigVal = -ordeig(SS,TT);
        EigVal = EigVal(:).';
        issevn2 = doSevn2Patch() | issevn2;
        if Opt.warning && issevn2
            utils.warning('model', ...
                ['Numerical instability in QZ decomposition. ', ...
                'SEVN2 patch applied.'])
        end
        
        % Undo the eigval inversion.
        infEigVal = EigVal == 0;
        EigVal(~infEigVal) = 1./EigVal(~infEigVal);
        EigVal(infEigVal) = Inf;
        nunit = sum(unit);
        nstable = sum(stable);
        
        % Check BK saddle-path condition.
        if any(isnan(EigVal))
            NPath(ialt) = -2;
        elseif nb == nstable + nunit
            NPath(ialt) = 1;
        elseif nb > nstable + nunit
            NPath(ialt) = 0;
        else
            NPath(ialt) = Inf;
        end
        
        function Flag = doSevn2Patch()
            % Sum of two eigvals near to 2 may indicate inaccuracy.
            % Largest eigval less than 1.
            Flag = false;
            eigval0 = EigVal;
            eigval0(abs(EigVal) >= 1-eigValTol) = 0;
            eigval0(imag(EigVal) ~= 0) = 0;
            if any(eigval0 ~= 0)
                [ans,below] = max(abs(eigval0)); %#ok<*NOANS,*ASGLU>
            else
                below = [];
            end
            % Smallest eig greater than 1.
            eigval0 = EigVal;
            eigval0(abs(EigVal) <= 1+eigValTol) = Inf;
            eigval0(imag(EigVal) ~= 0) = Inf;
            if any(~isinf(eigval0))
                [ans,above] = min(abs(eigval0));
            else
                above = [];
            end
            if ~isempty(below) && ~isempty(above) ...
                    && abs(EigVal(below) + EigVal(above) - 2) <= eigValTol ...
                    && abs(EigVal(below) - 1) <= 1e-6
                EigVal(below) = sign(EigVal(below));
                EigVal(above) = sign(EigVal(above));
                TT(below,below) = sign(TT(below,below))*abs(SS(below,below));
                TT(above,above) = sign(TT(above,above))*abs(SS(above,above));
                Flag = true;
            end
        end % doSevn2Patch().
        
    end % doSchur().

%**************************************************************************
    function flag = doSspace()
        
        flag = true;
        isnonlin = any(This.nonlin);
        S11 = SS(1:nb,1:nb);
        S12 = SS(1:nb,nb+1:end);
        S22 = SS(nb+1:end,nb+1:end);
        T11 = TT(1:nb,1:nb);
        T12 = TT(1:nb,nb+1:end);
        T22 = TT(nb+1:end,nb+1:end);
        Z11 = ZZ(fKeep,1:nb);
        Z12 = ZZ(fKeep,nb+1:end);
        Z21 = ZZ(nf+1:end,1:nb);
        Z22 = ZZ(nf+1:end,nb+1:end);
        
        % Transform the other system matrices by QQ.
        if eqorder(1) == 1
            % No equation re-ordering.
            % Constant.
            C = QQ*system.K{2};
            % Effect of transition shocks.
            D = QQ*full(system.E{2});
            if isnonlin
                % Effect of add-factors in transition equations earmarked
                % for non-linear simulations.
                N = QQ*system.N{2};
            end
        else
            % Equations have been re-ordered while computing QZ.
            % Constant.
            C = QQ*system.K{2}(eqorder,:);
            % Effect of transition shocks.
            D = QQ*full(system.E{2}(eqorder,:));
            if isnonlin
                % Effect of add-factors in transition equations earmarked
                % for non-linear simulations.
                N = QQ*system.N{2}(eqorder,:);
            end
        end
        
        C1 = C(1:nb,1);
        C2 = C(nb+1:end,1);
        D1 = D(1:nb,:);
        D2 = D(nb+1:end,:);
        if isnonlin
            N1 = N(1:nb,:);
            N2 = N(nb+1:end,:);
        end
        
        % Quasi-triangular state-space form.
        
        U = Z21;
        
        % Singularity in the rotation matrix; something's wrong with the model
        % because this is supposed to be regular by construction.
        if rcond(U) <= realSmall
            flag = false;
            return
        end
        
        % Steady state for non-linear models. They are needed in non-linear
        % models to back out the constant vectors.
        if ~Opt.linear
            ysstate = ...
                mytrendarray(This,This.solutionid{1},0,false,ialt);
            xfsstate = ...
                mytrendarray(This,This.solutionid{2}(1:nFKeep),[-1,0],false,ialt);
            xbsstate = ...
                mytrendarray(This,This.solutionid{2}(nFKeep+1:end),[-1,0],false,ialt);
            asstate = U \ xbsstate;
            if any(isnan(asstate(:)))
                flag = false;
                return
            end
        end
        
        % Unstable block.
        
        G = -Z21\Z22;
        if any(isnan(G(:)))
            flag = false;
            return
        end
        
        Ru = -T22\D2;
        if any(isnan(Ru(:)))
            flag = false;
            return
        end
        
        if isnonlin
            Yu = -T22\N2;
            if any(isnan(Yu(:)))
                flag = false;
                return
            end
        end
        
        if Opt.linear
            Ku = -(S22+T22)\C2;
        else
            Ku = zeros(nFKeep,1);
        end
        if any(isnan(Ku(:)))
            flag = false;
            return
        end
        
        % Transform stable block == transform backward-looking variables:
        % a(t) = s(t) + G u(t+1).
        
        Ta = -S11\T11;
        if any(isnan(Ta(:)))
            flag = false;
            return
        end
        Xa0 = S11\(T11*G + T12);
        if any(isnan(Xa0(:)))
            flag = false;
            return
        end
        
        Ra = -Xa0*Ru - S11\D1;
        if any(isnan(Ra(:)))
            flag = false;
            return
        end
        
        if isnonlin
            Ya = -Xa0*Yu - S11\N1;
            if any(isnan(Ya(:)))
                flag = false;
                return
            end
        end
        
        Xa1 = G + S11\S12;
        if any(isnan(Xa1(:)))
            flag = false;
            return
        end
        if Opt.linear
            Ka = -(Xa0 + Xa1)*Ku - S11\C1;
        else
            Ka = asstate(:,2) - Ta*asstate(:,1);
        end
        if any(isnan(Ka(:)))
            flag = false;
            return
        end
        
        % Forward-looking variables.
        
        % Duplicit rows (metadelete) already deleted from Z11 and Z12.
        Tf = Z11;
        Xf = Z11*G + Z12;
        Rf = Xf*Ru;
        if isnonlin
            Yf = Xf*Yu;
        end
        if Opt.linear
            Kf = Xf*Ku;
        else
            Kf = xfsstate(:,2) - Tf*asstate(:,1);
        end
        if any(isnan(Kf(:)))
            flag = false;
            return
        end
        
        % State-space form:
        % [xf(t);a(t)] = T a(t-1) + K + R(L) e(t) + Y(L) addfactor(t),
        % U a(t) = xb(t).
        T = [Tf;Ta];
        K = [Kf;Ka];
        R = [Rf;Ra];
        if isnonlin
            Y = [Yf;Ya];
        end
        
        % y(t) = Z a(t) + D + H e(t)
        if ny > 0
            ZZ = -full(system.A{1}\system.B{1});
            if any(isnan(ZZ(:)))
                flag = false;
                % Find singularities in measurement equations and their culprits.
                if rcond(full(system.A{1})) <= realSmall
                    s = size(system.A{1},1);
                    r = rank(full(system.A{1}));
                    d = s - r;
                    [U,S] = svd(full(system.A{1})); %#ok<NASGU>
                    Sing1(:,ialt) = ...
                        any(abs(U(:,end-d+1:end)) > realSmall,2);
                end
                return
            end
            H = -full(system.A{1}\system.E{1});
            if any(isnan(H(:)))
                flag = false;
                return
            end
            if Opt.linear
                D = full(-system.A{1}\system.K{1});
            else
                D = ysstate - ZZ*xbsstate(:,2);
            end
            if any(isnan(D(:)))
                flag = false;
                return
            end
            Z = ZZ*U;
        else
            Z = zeros(0,nb);
            H = zeros(0,ne);
            D = zeros(0,1);
        end
        
        % Necessary initial conditions in xb vector.
        if ExpMatrices
            This.icondix(1,:,ialt) = any(abs(T/U) > realSmall,1);
        end
        
        if ExpMatrices && ~isnan(Opt.expand)
            % Forward expansion.
            % a(t) <- -Xa J^(k-1) Ru e(t+k)
            % xf(t) <- Xf J^k Ru e(t+k)
            J = -T22\S22;
            Xa = Xa1 + Xa0*J;
            % Highest computed power of J: e(t+k) requires J^k.
            Jk = eye(size(J));
            
            This.Expand{1}(:,:,ialt) = Xa;
            This.Expand{2}(:,:,ialt) = Xf;
            This.Expand{3}(:,:,ialt) = Ru;
            This.Expand{4}(:,:,ialt) = J;
            This.Expand{5}(:,:,ialt) = Jk;
            if isnonlin
                This.Expand{6}(:,:,ialt) = Yu;
            end
        end
        
        This.solution{1}(:,:,ialt) = T;
        This.solution{2}(:,:,ialt) = R;
        This.solution{3}(:,:,ialt) = K;
        This.solution{4}(:,:,ialt) = Z;
        This.solution{5}(:,:,ialt) = H;
        This.solution{6}(:,:,ialt) = D;
        This.solution{7}(:,:,ialt) = U;
        if isnonlin
            This.solution{8}(:,:,ialt) = Y;
        end
        
    end % doSspace().

%**************************************************************************
    function doAllocSolution()
        if isempty(This.eigval)
            This.eigval = nan([1,nx,nAlt]);
        else
            This.eigval(:,:,IAlt) = NaN;
        end
        
        if isempty(This.icondix)
            This.icondix = false(1,nb,nAlt);
        else
            This.icondix(1,:,IAlt) = false;
        end
        
        if isnan(Opt.expand)
            This.Expand = {};
        else
            if isempty(This.Expand) || isempty(This.Expand{1})
                This.Expand{1} = nan(nb,nf,nAlt);
                This.Expand{2} = nan(nFKeep,nf,nAlt);
                This.Expand{3} = nan(nf,ne,nAlt);
                This.Expand{4} = nan(nf,nf,nAlt);
                This.Expand{5} = nan(nf,nf,nAlt);
                This.Expand{6} = nan(nf,nn,nAlt);
            else
                This.Expand{1}(:,:,IAlt) = NaN;
                This.Expand{2}(:,:,IAlt) = NaN;
                This.Expand{3}(:,:,IAlt) = NaN;
                This.Expand{4}(:,:,IAlt) = NaN;
                This.Expand{5}(:,:,IAlt) = NaN;
                This.Expand{6}(:,:,IAlt) = NaN;
            end
        end
        
        if isempty(This.solution) || isempty(This.solution{1})
            This.solution{1} = nan(nFKeep+nb,nb,nAlt); % T
            This.solution{2} = nan(nFKeep+nb,ne,nAlt); % R
            This.solution{3} = nan(nFKeep+nb,1,nAlt); % K
            This.solution{4} = nan(ny,nb,nAlt); % Z
            This.solution{5} = nan(ny,ne,nAlt); % H
            This.solution{6} = nan(ny,1,nAlt); % D
            This.solution{7} = nan(nb,nb,nAlt); % U
            This.solution{8} = nan(nFKeep+nb,nn,nAlt); % Y
        else
            This.solution{1}(:,:,IAlt) = nan(nFKeep+nb,nb,length(IAlt));
            if size(This.solution{2},2) > ne
                This.solution{2} = nan(nFKeep+nb,ne,nAlt);
            else
                This.solution{2}(:,:,IAlt) = nan(nFKeep+nb,ne,length(IAlt));
            end
            This.solution{3}(:,:,IAlt) = nan(nFKeep+nb,1,length(IAlt));
            This.solution{4}(:,:,IAlt) = nan(ny,nb,length(IAlt));
            This.solution{5}(:,:,IAlt) = nan(ny,ne,length(IAlt));
            This.solution{6}(:,:,IAlt) = nan(ny,1,length(IAlt));
            This.solution{7}(:,:,IAlt) = nan(nb,nb,length(IAlt));
            if size(This.solution{8},2) > nn
                This.solution{8} = nan(nFKeep+nb,nn,nAlt);
            else
                This.solution{8}(:,:,IAlt) = nan(nFKeep+nb,nn,length(IAlt));
            end
        end
    end % doAllocSolution().

end
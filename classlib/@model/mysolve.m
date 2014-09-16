function [This,NPath,NanDerv,Sing1] = mysolve(This,SelAlt,Opt)
% mysolve  [Not a public function] First-order quasi-triangular solution.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

% NPath
%
% * 1 .. Unique stable solution
% * 0 .. No stable solution (all explosive)
% * Inf .. Multiple stable solutions
% * -1 .. NaN in solved matrices
% * -2 .. NaN in eigenvalues
% * -3 .. NaN derivatives in system matrices
% * -4 .. Steady state does not hold

try
    SelAlt;
catch %#ok<CTCH>
    SelAlt = 1;
end

%--------------------------------------------------------------------------

isTrans = ~strcmpi(Opt.eqtn,'measurement');
isMeas = ~strcmpi(Opt.eqtn,'transition');

eigValTol = This.Tolerance(1);
realSmall = getrealsmall();

ny = sum(This.nametype == 1);
nx = length(This.systemid{2});
nb = sum(imag(This.systemid{2}) < 0);
nf = nx - nb;
ne = sum(This.nametype == 3);
nn = sum(This.IxNonlin);
fKeep = ~This.d2s.remove;
nfKeep = sum(fKeep);
nxKeep = nfKeep + nb;
nAlt = size(This.Assign,3);

if islogical(SelAlt)
    SelAlt = find(SelAlt);
elseif isequal(SelAlt,Inf)
    SelAlt = 1 : nAlt;
end

% Reset icondix, eigenvalues, solution matrices, expansion matrices
% depending on `isTransition` and `isMeasurement`.
doReset();

% Set `NPATH` to 1 initially to handle correctly the cases when only a
% subset of parameterisations is solved for.
NPath = ones(1,nAlt);
SelAlt = SelAlt(:).';

if Opt.progress
    progress = progressbar('IRIS model.solve progress');
end

Sing1 = false(sum(This.eqtntype == 1),nAlt);
NanDerv = cell(1,nAlt);

for iAlt = SelAlt

    % Differentiate equations and set up unsolved system matrices; check
    % for NaN derivatives.
    [syst,NanDerv{iAlt}] = mysystem(This,iAlt,Opt);
    if any(NanDerv{iAlt})
        NPath(iAlt) = -3;
        continue
    end
    
    % Check system matrices for complex numbers.
    if ~isreal(syst.K{1}) ...
            || ~isreal(syst.K{2}) ...
            || ~isreal(syst.A{1}) ...
            || ~isreal(syst.A{2}) ...
            || ~isreal(syst.B{1}) ...
            || ~isreal(syst.B{2}) ...
            || ~isreal(syst.E{1}) ...
            || ~isreal(syst.E{2})
        NPath(iAlt) = 1i;
        continue;
    end
    % Check system matrices for NaNs.
    if any(isnan(syst.K{1})) ...
            || any(isnan(syst.K{2})) ...
            || any(isnan(syst.A{1}(:))) ...
            || any(isnan(syst.A{2}(:))) ...
            || any(isnan(syst.B{1}(:))) ...
            || any(isnan(syst.B{2}(:))) ...
            || any(isnan(syst.E{1}(:))) ...
            || any(isnan(syst.E{2}(:)))
        NPath(iAlt) = NaN;
        continue;
    end
    
    % Schur decomposition and saddle-path check
    %-------------------------------------------
    if isTrans
        [SS,TT,QQ,ZZ,eqOrd] = doSchur();
    end
    
    if NPath(iAlt) == 1
        if ~Opt.linear
            % Steady-state levels needed in doTransition() and
            % doMeasurement().
            isDelog = false;
            ssY = mytrendarray(This,iAlt,isDelog, ...
                find(This.nametype == 1),0);
            ssXf = mytrendarray(This,iAlt,isDelog, ...
                This.solutionid{2}(1:nfKeep),[-1,0]);
            ssXb = mytrendarray(This,iAlt,isDelog, ...
                This.solutionid{2}(nfKeep+1:end),[-1,0]);
        end
        
        % Solution matrices
        %-------------------
        flagTrans = true;
        flagMeas = true;
        if isMeas
            % Measurement matrices.
            flagMeas = doMeas();
        end
        if isTrans
            % Transition matrices.
            flagTrans = doTrans();
        end
        if ~flagTrans || ~flagMeas
            if ~This.IsLinear && ~mychksstate(This)
                NPath(iAlt) = -4;
                continue;
            else
                NPath(iAlt) = -1;
                continue;
            end
        end
        % Transformed measurement matrices.
        doTransformMeas();
        
        % Forward expansion of solution matrices
        %----------------------------------------
        if isTrans && Opt.expand > 0
            [newR,newY,newJk] = model.myexpand( ...
                This.solution{2}(:,:,iAlt), ...
                This.solution{8}(:,:,iAlt), ...
                Opt.expand, ...
                This.Expand{1}(:,:,iAlt), ...
                This.Expand{2}(:,:,iAlt), ...
                This.Expand{3}(:,:,iAlt), ...
                This.Expand{4}(:,:,iAlt), ...
                This.Expand{5}(:,:,iAlt), ...
                This.Expand{6}(:,:,iAlt));
            This.solution{2}(:,:,iAlt) = newR;
            This.solution{8}(:,:,iAlt) = newY;
            This.Expand{5}(:,:,iAlt) = newJk;
        end
        
    end
    
    if Opt.progress
        update(progress,iAlt/length(SelAlt));
    end

end


% Nested functions...


%**************************************************************************


    function [SS,TT,QQ,ZZ,eqOrd] = doSchur()
        % Ordered real QZ decomposition.
        fA = full(syst.A{2});
        fB = full(syst.B{2});
        eqOrd = 1 : size(fA,1);
        % If the QZ re-ordering fails, change the order of equations --
        % place the first equation last, and repeat.
        warning('off','MATLAB:ordqz:reorderingFailed');
        while true
            AA = fA(eqOrd,:);
            BB = fB(eqOrd,:);
            if false % ##### MOSW
                [SS,TT,QQ,ZZ] = qz(AA,BB,'real');
                % Ordered inverse eigvals.
                eigVal = -ordeig(SS,TT);
            else
                lastwarn('');
                [SS,TT,QQ,ZZ,eigVal] = mosw.octfun.ordqz(AA,BB,eigValTol); % leading block has ||eigVals| - 1| < eigValTol; next block has |eigVals| >= 1 + eigValTol
                isEmptyWarn = isempty(lastwarn());
                % Ordered inverse eigvals.
                eigVal = -eigVal;
            end
            eigVal = eigVal(:).';
            isSevn2 = doSevn2Patch();
            stable = abs(eigVal) >= 1 + eigValTol;
            unit = abs(abs(eigVal)-1) < eigValTol;
            if false % ##### MOSW
                % Clusters of unit, stable, and unstable eigenvalues.
                clusters = zeros(size(eigVal));
                % Unit roots first.
                clusters(unit) = 2;
                % Stable roots second.
                clusters(stable) = 1;
                % Unstable roots last.
                % Re-order by the clusters.
                lastwarn('');
                [SS,TT,QQ,ZZ] = ordqz(SS,TT,QQ,ZZ,clusters);
                isEmptyWarn = isempty(lastwarn());
            end
            % If the first equations is ordered second, it indicates the
            % next cycle would bring the equations to their original order.
            % We stop and throw an error.
            if isEmptyWarn || eqOrd(2) == 1
                break
            else
                eqOrd = eqOrd([2:end,1]);
            end
        end
        warning('on','MATLAB:ordqz:reorderingFailed');
        if ~isEmptyWarn
            utils.error('model', ...
                ['QZ re-ordering failed because ', ...
                'some eigenvalues are too close to swap, and ', ...
                'equation re-ordering does not help.']);
        end
        if Opt.warning && eqOrd(1) ~= 1
            utils.warning('model', ...
                ['Numerical instability in QZ decomposition. ', ...
                'Equations re-ordered %g time(s).'], ...
                eqOrd(1)-1);
        end
        
        % Re-order the inverse eigvals.
        if false % ##### MOSW
            eigVal = -ordeig(SS,TT);
            eigVal = eigVal(:).';
            isSevn2 = doSevn2Patch() | isSevn2;
        end
        if Opt.warning && isSevn2
            utils.warning('model', ...
                ['Numerical instability in QZ decomposition. ', ...
                'SEVN2 patch applied.'])
        end
        
        % Undo the eigval inversion.
        isInfEigVal = eigVal == 0;
        eigVal(~isInfEigVal) = 1./eigVal(~isInfEigVal);
        eigVal(isInfEigVal) = Inf;
        nUnit = sum(unit);
        nStable = sum(stable);
        
        % Check BK saddle-path condition.
        if any(isnan(eigVal))
            NPath(iAlt) = -2;
        elseif nb == nStable + nUnit
            NPath(iAlt) = 1;
        elseif nb > nStable + nUnit
            NPath(iAlt) = 0;
        else
            NPath(iAlt) = Inf;
        end
        This.eigval(1,:,iAlt) = eigVal;
        
        
        function Flag = doSevn2Patch()
            % Sum of two eigvals near to 2 may indicate inaccuracy.
            % Largest eigval less than 1.
            Flag = false;
            eigval0 = eigVal;
            eigval0(abs(eigVal) >= 1-eigValTol) = 0;
            eigval0(imag(eigVal) ~= 0) = 0;
            if any(eigval0 ~= 0)
                [ans,below] = max(abs(eigval0)); %#ok<*NOANS,*ASGLU>
            else
                below = [];
            end
            % Smallest eig greater than 1.
            eigval0 = eigVal;
            eigval0(abs(eigVal) <= 1+eigValTol) = Inf;
            eigval0(imag(eigVal) ~= 0) = Inf;
            if any(~isinf(eigval0))
                [ans,above] = min(abs(eigval0));
            else
                above = [];
            end
            if ~isempty(below) && ~isempty(above) ...
                    && abs(eigVal(below) + eigVal(above) - 2) <= eigValTol ...
                    && abs(eigVal(below) - 1) <= 1e-6
                eigVal(below) = sign(eigVal(below));
                eigVal(above) = sign(eigVal(above));
                TT(below,below) = sign(TT(below,below))*abs(SS(below,below));
                TT(above,above) = sign(TT(above,above))*abs(SS(above,above));
                Flag = true;
            end
        end % doSevn2Patch()
        
        
    end % doSchur()


%**************************************************************************


    function Flag = doTrans()
        
        Flag = true;
        isNonlin = any(This.IxNonlin);
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
        if eqOrd(1) == 1
            % No equation re-ordering.
            % Constant.
            C = QQ*syst.K{2};
            % Effect of transition shocks.
            D = QQ*full(syst.E{2});
            if isNonlin
                % Effect of add-factors in transition equations earmarked
                % for non-linear simulations.
                N = QQ*syst.N{2};
            end
        else
            % Equations have been re-ordered while computing QZ.
            % Constant.
            C = QQ*syst.K{2}(eqOrd,:);
            % Effect of transition shocks.
            D = QQ*full(syst.E{2}(eqOrd,:));
            if isNonlin
                % Effect of add-factors in transition equations earmarked
                % for non-linear simulations.
                N = QQ*syst.N{2}(eqOrd,:);
            end
        end
        
        C1 = C(1:nb,1);
        C2 = C(nb+1:end,1);
        D1 = D(1:nb,:);
        D2 = D(nb+1:end,:);
        if isNonlin
            N1 = N(1:nb,:);
            N2 = N(nb+1:end,:);
        end
        
        % Quasi-triangular state-space form.
        
        U = Z21;
        
        % Singularity in the rotation matrix; something's wrong with the model
        % because this is supposed to be regular by construction.
        if rcond(U) <= realSmall
            Flag = false;
            return
        end
        
        % Steady state for non-linear models. They are needed in non-linear
        % models to back out the constant vectors.
        if ~Opt.linear
            ssA = U \ ssXb;
            if any(isnan(ssA(:)))
                Flag = false;
                return
            end
        end
        
        % Unstable block.
        
        G = -Z21\Z22;
        if any(isnan(G(:)))
            Flag = false;
            return
        end
        
        Ru = -T22\D2;
        if any(isnan(Ru(:)))
            Flag = false;
            return
        end
        
        if isNonlin
            Yu = -T22\N2;
            if any(isnan(Yu(:)))
                Flag = false;
                return
            end
        end
        
        if Opt.linear
            Ku = -(S22+T22)\C2;
        else
            Ku = zeros(nfKeep,1);
        end
        if any(isnan(Ku(:)))
            Flag = false;
            return
        end
        
        % Transform stable block == transform backward-looking variables:
        % a(t) = s(t) + G u(t+1).
        
        Ta = -S11\T11;
        if any(isnan(Ta(:)))
            Flag = false;
            return
        end
        Xa0 = S11\(T11*G + T12);
        if any(isnan(Xa0(:)))
            Flag = false;
            return
        end
        
        Ra = -Xa0*Ru - S11\D1;
        if any(isnan(Ra(:)))
            Flag = false;
            return
        end
        
        if isNonlin
            Ya = -Xa0*Yu - S11\N1;
            if any(isnan(Ya(:)))
                Flag = false;
                return
            end
        end
        
        Xa1 = G + S11\S12;
        if any(isnan(Xa1(:)))
            Flag = false;
            return
        end
        if Opt.linear
            Ka = -(Xa0 + Xa1)*Ku - S11\C1;
        else
            Ka = ssA(:,2) - Ta*ssA(:,1);
        end
        if any(isnan(Ka(:)))
            Flag = false;
            return
        end
        
        % Forward-looking variables.
        
        % Duplicit rows have been already deleted from Z11 and Z12.
        Tf = Z11;
        Xf = Z11*G + Z12;
        Rf = Xf*Ru;
        if isNonlin
            Yf = Xf*Yu;
        end
        if Opt.linear
            Kf = Xf*Ku;
        else
            Kf = ssXf(:,2) - Tf*ssA(:,1);
        end
        if any(isnan(Kf(:)))
            Flag = false;
            return
        end
        
        % State-space form:
        % [xf(t);a(t)] = T a(t-1) + K + R(L) e(t) + Y(L) addfactor(t),
        % U a(t) = xb(t).
        T = [Tf;Ta];
        K = [Kf;Ka];
        R = [Rf;Ra];
        if isNonlin
            Y = [Yf;Ya];
        end
        
        This.solution{1}(:,:,iAlt) = T;
        This.solution{2}(:,1:ne,iAlt) = R;
        This.solution{3}(:,:,iAlt) = K;
        This.solution{7}(:,:,iAlt) = U;
        if isNonlin
            This.solution{8}(:,1:nn,iAlt) = Y;
        end
        
        % Necessary initial conditions in xb vector.
        if ~Opt.fast
            This.icondix(1,:,iAlt) = any(abs(T/U) > realSmall,1);
        end
        
        if ~isempty(This.Expand)
            % Forward expansion.
            % a(t) <- -Xa J^(k-1) Ru e(t+k)
            % xf(t) <- Xf J^k Ru e(t+k)
            J = -T22\S22;
            Xa = Xa1 + Xa0*J;
            % Highest computed power of J: e(t+k) requires J^k.
            Jk = eye(size(J));
            
            This.Expand{1}(:,:,iAlt) = Xa;
            This.Expand{2}(:,:,iAlt) = Xf;
            This.Expand{3}(:,:,iAlt) = Ru;
            This.Expand{4}(:,:,iAlt) = J;
            This.Expand{5}(:,:,iAlt) = Jk;
            if isNonlin
                This.Expand{6}(:,:,iAlt) = Yu;
            end
        end
                
    end % doTrans()


%**************************************************************************


    function Flag = doMeas()
        Flag = true;
        % First, create untransformed measurement equation; the transformed
        % measurement matrix will be calculated later on.
        % y(t) = ZZ xb(t) + D + H e(t)
        if ny > 0
            Zb = -full(syst.A{1}\syst.B{1});
            if any(isnan(Zb(:)))
                Flag = false;
                % Find singularities in measurement equations and their culprits.
                if rcond(full(syst.A{1})) <= realSmall
                    s = size(syst.A{1},1);
                    r = rank(full(syst.A{1}));
                    d = s - r;
                    [u,~] = svd(full(syst.A{1}));
                    Sing1(:,iAlt) = ...
                        any(abs(u(:,end-d+1:end)) > realSmall,2);
                end
                return
            end
            H = -full(syst.A{1}\syst.E{1});
            if any(isnan(H(:)))
                Flag = false;
                return
            end
            if Opt.linear
                D = full(-syst.A{1}\syst.K{1});
            else
                D = ssY - Zb*ssXb(:,2);
            end
            if any(isnan(D(:)))
                Flag = false;
                return
            end
        else
            Zb = zeros(0,nb);
            H = zeros(0,ne);
            D = zeros(0,1);
        end
        % This.solution{4}(:,:,iAlt) is assigned later on.
        This.solution{5}(:,:,iAlt) = H;
        This.solution{6}(:,:,iAlt) = D;
        This.solution{9}(:,:,iAlt) = Zb;
    end % doMeasurement()


%**************************************************************************


    function doTransformMeas()
        % Transform the Zb matrix to Z:
        %     y = Zb*xb -> y = Z*alp
        Zb = This.solution{9}(:,:,iAlt);
        U = This.solution{7}(:,:,iAlt);
        Z = Zb*U;
        This.solution{4}(:,:,iAlt) = Z;
    end % doTransformMeas()


%**************************************************************************


    function doReset()
        
        k = Opt.expand;
        if isempty(This.solution) || isempty(This.solution{1})
            % Preallocate nonexisting solution matrices.
            % Transition matrices.
            This.solution{1} = nan(nxKeep,nb,nAlt); % T
            This.solution{2} = nan(nxKeep,ne*(k+1),nAlt); % R
            This.solution{3} = nan(nxKeep,1,nAlt); % K
            % Measurement matrices.
            This.solution{4} = nan(ny,nb,nAlt); % Z
            This.solution{5} = nan(ny,ne,nAlt); % H
            This.solution{6} = nan(ny,1,nAlt); % D
            % Transformation of the alpha vector.
            This.solution{7} = nan(nb,nb,nAlt); % U
            % Effect of nonlinearirities.
            This.solution{8} = nan(nxKeep,nn*(k+1),nAlt); % Y
            % Auxiliary measurement matrix y = Zb*xb;
            This.solution{9} = nan(ny,nb,nAlt); % Zb
        end
        
        if isempty(This.eigval)
            This.eigval = nan(1,nx,nAlt);
        end
        
        if isempty(This.icondix)
            This.icondix = false(1,nb,nAlt);
        end
                    
        if Opt.fast && Opt.expand == 0
            % Do not compute expansion matrices (fast calls to mysolve with
            % no expansion requested); assign an empty cell.
            This.Expand = {};
        elseif isempty(This.Expand) || isempty(This.Expand{1})
            % Preallocate nonexisting expansion matrices.
            This.Expand{1} = nan(nb,nf,nAlt);
            This.Expand{2} = nan(nfKeep,nf,nAlt);
            This.Expand{3} = nan(nf,ne,nAlt);
            This.Expand{4} = nan(nf,nf,nAlt);
            This.Expand{5} = nan(nf,nf,nAlt);
            This.Expand{6} = nan(nf,nn,nAlt);
        end
        
        nSelAlt = length(SelAlt);
        if isTrans            
            % Reset transition solution matrices.
            This.solution{1}(:,:,SelAlt) = nan(nxKeep,nb,nSelAlt);
            n = size(This.solution{2},2);
            if n < ne*(k+1)
                This.solution{2} = [This.solution{2}, ...
                    nan(nxKeep,ne*(k+1)-n,nAlt)];
                n = ne*(k+1);
            end
            This.solution{2}(:,:,SelAlt) = nan(nxKeep,n,nSelAlt);
            This.solution{3}(:,:,SelAlt) = nan(nxKeep,1,nSelAlt);
            This.solution{7}(:,:,SelAlt) = nan(nb,nb,nSelAlt);
            n = size(This.solution{8},2);
            if n < nn*(k+1)
                This.solution{8}(:,end+1:nn*(k+1),:) = NaN;
                This.solution{8} = [This.solution{8}, ...
                    nan(nxKeep,nn*(k+1)-n,nAlt)];
                n = nn*(k+1);
            end
            This.solution{8}(:,:,SelAlt) = nan(nxKeep,n,nSelAlt);
            
            % Reset transition properties.
            This.eigval(:,:,SelAlt) = NaN;
            This.icondix(1,:,SelAlt) = false;

            % Reset expansion matrices.
            if ~isempty(This.Expand) && nf > 0
                This.Expand{1}(:,:,SelAlt) = NaN;
                This.Expand{2}(:,:,SelAlt) = NaN;
                This.Expand{3}(:,:,SelAlt) = NaN;
                This.Expand{4}(:,:,SelAlt) = NaN;
                This.Expand{5}(:,:,SelAlt) = NaN;
                This.Expand{6}(:,:,SelAlt) = NaN;
            end
        end
        
        if isMeas
            % Reset measurement solution matrices.
            This.solution{5}(:,:,SelAlt) = nan(ny,ne,nSelAlt);
            This.solution{6}(:,:,SelAlt) = nan(ny,1,nSelAlt);
            This.solution{9}(:,:,SelAlt) = nan(ny,nb,nAlt);
        end
        
        % Reset This.solution{4} no matter what: it depends both on
        % transition and measurement parameters and needs to be always
        % updated.
        This.solution{4}(:,:,SelAlt) = nan(ny,nb,nSelAlt);
        
    end % doReset()


end

function  [This,Flag] = mysstatelinear(This,Opt)
% mysstatelinear  [Not a public function] Steady-state solver for linear models.
%
% Backed IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

try
    isWarn = isequal(Opt.warning,true);
catch %#ok<CTCH>
    isWarn = true;
end

%--------------------------------------------------------------------------

doRefresh();

eigValTol = This.Tolerance(1);
realSmall = getrealsmall();
ny = sum(This.nametype == 1);
nAlt = size(This.Assign,3);

[Flag,isNanSol] = isnan(This,'solution');
if isWarn && Flag
    utils.warning('model', ...
        ['Cannot compute linear steady state ', ...
        'because solution is not available %s.'], ...
        preparser.alt2str(isNanSol));
end

isDiffStat = true(1,nAlt);
for iAlt = find(~isNanSol)
    doOneSstate();
end

% Some parameterizations are not difference stationary.
if any(~isDiffStat)
    utils.warning('model', ...
        ['Model is not difference stationary. ', ...
        'Some steady-state growth rates are not fixed numbers %s.'], ...
        preparser.alt2str(~isDiffStat));
end


if any(This.log)
    realAssign = real(This.Assign(1,This.log,:));
    imagAssign = imag(This.Assign(1,This.log,:));
    This.Assign(1,This.log,:) = exp(realAssign) + 1i*exp(imagAssign);
end

doRefresh();


% Nested functions...


%**************************************************************************
    function doRefresh()
        if ~isempty(This.Refresh) && Opt.refresh
            This = refresh(This);
        end
    end % doRefresh()


%**************************************************************************
    function doOneSstate()
        T = This.solution{1}(:,:,iAlt);
        K = This.solution{3}(:,:,iAlt);
        Z = This.solution{4}(:,:,iAlt);
        D = This.solution{6}(:,:,iAlt);
        U = This.solution{7}(:,:,iAlt);
        [nx,nb] = size(T);
        nUnit = mynunit(This,iAlt);
        nf = nx - nb;
        nStable = nb - nUnit;
        Tf = T(1:nf,:);
        Ta = T(nf+1:end,:);
        Kf = K(1:nf,1);
        Ka = K(nf+1:end,1);
        
        % Alpha vector
        %--------------
        if any(any(abs(Ta(1:nUnit,1:nUnit) - eye(nUnit)) > eigValTol))
            % I(2) or higher-order systems. Write the steady-state system at two
            % different times: t and t+d.
            d = 10;
            E1 = [eye(nb),zeros(nb);eye(nb),d*eye(nb)];
            E2 = [Ta,-Ta;Ta,(d-1)*Ta];
            temp = pinv(E1 - E2) * [Ka;Ka];
            a2 = temp(nUnit+(1:nStable));
            da1 = temp(nb+(1:nUnit));
            isDiffStat(iAlt) = false;
        else
            % I(0) or I(1) systems.
            a2 = (eye(nStable) - Ta(nUnit+1:end,nUnit+1:end)) ...
                \ Ka(nUnit+1:end,1);
            da1 = Ta(1:nUnit,nUnit+1:end)*a2 + Ka(1:nUnit,1);
        end
        
        % Transition variables
        %----------------------
        x = [Tf*[-da1;a2]+Kf;U(:,nUnit+1:end)*a2];
        dx = [Tf(:,1:nUnit)*da1;U(:,1:nUnit)*da1];
        x(abs(x) <= realSmall) = 0;
        dx(abs(dx) <= realSmall) = 0;
        realId = real(This.solutionid{2});
        imagId = imag(This.solutionid{2});
        iinx = imagId == 0;
        realId(~iinx) = [];
        x(~iinx) = [];
        dx(~iinx) = [];
        This.Assign(1,realId,iAlt) = x(:).' + 1i*dx(:).';
        
        % Measurement variables
        %-----------------------
        if ny > 0
            y = Z(:,nUnit+1:end)*a2 + D;
            dy = Z(:,1:nUnit)*da1;
            This.Assign(1,This.nametype == 1,iAlt) = y(:).' + 1i*dy(:).';
        end
    end % doOneSstate()

end
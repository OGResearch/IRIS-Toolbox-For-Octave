function  [This,Success] = mysstatenonlin(This,Opt)
% mysstatenonlin [Not a public function] Steady-state solver for non-linear models.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

fixL = Opt.fixL;
fixG = Opt.fixG;
nameBlkL = Opt.nameBlkL;
nameBlkG = Opt.nameBlkG;
eqtnBlk = Opt.eqtnBlk;
blkFunc = Opt.blkFunc;
endogLInx = Opt.endogLInx;
endogGInx = Opt.endogGInx;
zeroLInx = Opt.zeroLInx;
zeroGInx = Opt.zeroGInx;

%--------------------------------------------------------------------------

Shift = 10;
nAlt = size(This.Assign,3);
Success = true(1,nAlt);

doRefresh();

% Set the level and growth of optimal policy multipliers to zero. We must
% do this before checking for NaNs in fixed variables.
if Opt.zeromultipliers
    This.Assign(1,This.multiplier,:) = 0;
end

% Check for levels and growth rate fixed to NaNs.
doChkForNans();

x0 = [];
for iAlt = 1 : nAlt
    
    % Initialise levels
    %-------------------
    x = real(This.Assign(1,:,iAlt));
    % Level variables that are set to zero (shocks).
    x(zeroLInx) = 0;
    if ~isempty(Opt.resetinit)
        x(:) = real(Opt.resetinit);
        x(This.LogSign == 1) = exp(x(This.LogSign == 1));
        x(This.LogSign == -1) = -exp(x(This.LogSign == -1));
    else
        % Assign NaN level initial conditions.
        % First, assign values from the previous iteration (if they exist).
        inx = isnan(x) & endogLInx;
        if Opt.reuse && any(inx) && ~isempty(x0)
            x(inx) = x0(inx);
            inx = isnan(x) & endogLInx;
        end
        % Then, if there still some NaNs left, use the option `'nanInit='`
        % to assign them.
        x(inx) = real(Opt.naninit);
    end
    
    % Initialise growth rates
    %-------------------------
    dx = imag(This.Assign(1,:,iAlt));
    % Growth variables that are set to zero (all variables if `'growth='
    % false`.
    dx(zeroGInx) = 0;
    if any(~zeroGInx)
        if ~isempty(Opt.resetinit)
            dx(:) = imag(Opt.resetinit);
            dx(This.LogSign ~= 0) = exp(dx(This.LogSign ~= 0));
        else
            % Assign NaN growth initial conditions.
            % First, assign values from the previous iteration (if they exist).
            inx = isnan(dx) & endogGInx;
            if Opt.reuse && any(inx) && ~isempty(dx0)
                dx(inx) = dx0(inx);
                inx = isnan(dx) & endogLInx;
            end
            % Then, if there still some NaNs left, use the option `'NaN='` to assign
            % them.
            dx(inx) = imag(Opt.naninit);
        end
    end
    % Re-assign zero growth for log-variables to 1.
    dx(dx == 0 & This.LogSign ~= 0) = 1;
        
    % Cycle over individual blocks
    %------------------------------
    nBlk = length(nameBlkL);
    for iBlk = 1 : nBlk
        if isempty(nameBlkL{iBlk}) && isempty(nameBlkG{iBlk})
            continue
        end

        xi = nameBlkL{iBlk};
        dxi = nameBlkG{iBlk};
        ixLogPlus = This.LogSign(xi) == 1;
        ixLogMinus = This.LogSign(xi) == -1;
        % Log growth rates are always positive.
        ixDLog = This.LogSign(dxi) ~= 0;
        ixLogPlus = [ixLogPlus,ixDLog]; %#ok<AGROW>
        ixLogMinus = [ixLogMinus,false(size(dxi))]; %#ok<AGROW>
        z0 = [x(xi),dx(dxi)];
        z0(ixLogPlus) = log(z0(ixLogPlus));
        z0(ixLogMinus) = log(-z0(ixLogMinus));
        
        % Test all equations in this block for NaNs and INfs.
        if Opt.warning
            check = blkFunc{iBlk}(x,dx);
            inx = isnan(check) | isinf(check);
            if any(inx)
                utils.warning('model', ...
                    'This equation evaluates to NaN or Inf: ''%s''.', ...
                    This.eqtn{eqtnBlk{iBlk}(inx)});
            end
        end
        
        % Number of levels; this variables is used also within
        % `doObjFunc()`.
        nxi = length(xi);
        
        % Function handles to equations in this block.
        f = blkFunc{iBlk};
        
        % Call the solver.
        if Opt.ixAssign(iBlk)
            
            % Plain assignment; `xi` and `dxi` each is either empty or
            % scalar.
            z = [];
            y0 = f(x,dx);
            if ~isempty(xi)
                z = [z,y0]; %#ok<AGROW>
            end
            if ~isempty(dxi)
                xk = x;
                xk(This.LogSign == 0) = ...
                    x(This.LogSign == 0) + Shift*dx(This.LogSign == 0);
                % Time shifts of log-plus and log-variables are computed
                % the same way.
                xk(This.LogSign ~= 0) = ...
                    x(This.LogSign ~= 0) .* dx(This.LogSign ~= 0).^Shift;
                yk = f(xk,dx);
                if ixDLog
                    z = [z,(yk/y0)^(1/Shift)]; %#ok<AGROW>
                else
                    z = [z,(yk-y0)/Shift]; %#ok<AGROW>
                end
            end
            exitFlag = 1;

        else
            switch lower(char(Opt.solver))
                case 'lsqnonlin'
                    [z,~,~,exitFlag] = ...
                        lsqnonlin(@doObjFunc,z0,[],[],Opt.optimset);
                    if exitFlag == -3
                        exitFlag = 1;
                    end
                case 'fsolve'
                    [z,~,exitFlag] = fsolve(@doObjFunc,z0,Opt.optimset);
                    if exitFlag == -3
                        exitFlag = 1;
                    end
            end
            z(abs(z) <= Opt.optimset.TolX) = 0; %#ok<AGROW>
            z(ixLogPlus) = exp(z(ixLogPlus)); %#ok<AGROW>
            z(ixLogMinus) = -exp(z(ixLogMinus)); %#ok<AGROW>
        end
        
        x(xi) = z(1:nxi);
        dx(dxi) = z(nxi+1:end);
        iSuccess = ~any(isnan(z)) && double(exitFlag) > 0;
        Success(iAlt) = Success(iAlt) && iSuccess;
    end

    % TODO: Report more details on which equations and which variables failed.
    if Opt.warning && ~Success(iAlt)
        utils.warning('model', ...
            'Steady state inaccurate or not returned for some variables.');
    end
    
    This.Assign(1,:,iAlt) = x + 1i*dx;
    
    % Store the current values to initialise the next parameterisation.
    x0 = x;
    dx0 = dx;
    
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


    function Y = doObjFunc(P)
        % doobjfunc  This is the objective function for the solver. Evaluate the
        % equations twice, at time t and t+Shift.
       
        % Split the vector of unknows into levels and growth rates; `nxi` is the
        % number of levels.
        P(ixLogPlus) = exp(P(ixLogPlus));
        P(ixLogMinus) = -exp(P(ixLogMinus));
        x(xi) = P(1:nxi);
        dx(dxi) = P(nxi+1:end);
        
        % Refresh all dynamic links.
        if ~isempty(This.Refresh)
            doRefresh();
        end
        
        Y = f(x,dx);
        if any(dxi)
            % Some growth rates need to be calculated. Evaluate the model equations at
            % time t and t+Shift if at least one growth rate is needed.
            xk = x;
            xk(This.LogSign == 0) = ...
                x(This.LogSign == 0) + Shift*dx(This.LogSign == 0);
            % Time shifts of log-plus and log-variables are computed
            % the same way.
            xk(This.LogSign ~= 0) = ...
                x(This.LogSign ~= 0) .* dx(This.LogSign ~= 0).^Shift;
            Y = [Y;f(xk,dx)];
        end

        
        function doRefresh()
            % dorefresh  Refresh dynamic links in each iteration.
            This.Assign(1,:,iAlt) = x + 1i*dx;
            This = refresh(This,iAlt);
            x = real(This.Assign(1,:,iAlt));
            dx = imag(This.Assign(1,:,iAlt));
            dx(dx == 0 & This.LogSign ~= 0) = 1;
        end % doRefresh()
        
        
    end % doObjFunc()


%**************************************************************************


    function doChkForNans()
        % Check for levels fixed to NaN.
        fixLevelInx = false(1,length(This.name));
        fixLevelInx(fixL) = true;
        nanSstate = any(isnan(real(This.Assign)),3) & fixLevelInx;
        if any(nanSstate)
            utils.error('model', ...
                ['Cannot fix steady-state level for this variable ', ...
                'because it is NaN: ''%s''.'], ...
                This.name{nanSstate});
        end
        % Check for growth rates fixed to NaN.
        fixGrowthInx = false(1,length(This.name));
        fixGrowthInx(fixG) = true;
        nanSstate = any(isnan(imag(This.Assign)),3) & fixGrowthInx;
        if any(nanSstate)
            utils.error('model', ...
                ['Cannot fix steady-state growth for this variable ', ...
                'because it is NaN: ''%s''.'], ...
                This.name{nanSstate});
        end
    end % dochkfornans()


end
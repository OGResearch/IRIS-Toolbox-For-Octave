function  [This,Success] = mysstatenonlin(This,Opt)
% mysstatenonlin [Not a public function] Steady-state solver for non-linear models.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

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
    else
        % Assign NaN level initial conditions.
        % First, assign values from the previous iteration (if they exist).
        inx = isnan(x) & endogLInx;
        if Opt.reuse && any(inx) && ~isempty(x0)
            x(inx) = x0(inx);
            inx = isnan(x) & endogLInx;
        end
        % Then, if there still some NaNs left, use the option `'NaN='` to assign
        % them.
        x(inx) = real(Opt.naninit);
        x(This.log) = log(x(This.log));
    end
    
    % Initialise growth rates
    %-------------------------
    dx = imag(This.Assign(1,:,iAlt));
    % Growth variables that are set to zero (shocks).
    dx(zeroGInx) = 0;
    if ~isempty(Opt.resetinit)
        dx(:) = imag(Opt.resetinit);
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
    % Re-assign zero growth for log-variables to 1.
    dx(dx == 0 & This.log) = 1;
    dx(This.log) = log(dx(This.log));
        
    % Cycle over individual blocks
    %------------------------------
    nBlk = length(nameBlkL);
    for iBlk = 1 : nBlk
        if isempty(nameBlkL{iBlk}) && isempty(nameBlkG{iBlk})
            continue
        end

        xi = nameBlkL{iBlk};
        dxi = nameBlkG{iBlk};
        z0 = [x(xi),dx(dxi)];
        
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
        
        % Number of levels; this variables is used also within `doobjfunc`.
        nxi = length(xi);
        
        % Function handles to equations in this block.
        f = blkFunc{iBlk};
        
        % Call the solver.
        switch lower(char(Opt.solver))
            case 'lsqnonlin'
                [z,resnorm,residual,exitflag] = ...
                    lsqnonlin(@doObjFunc,z0,[],[],Opt.optimset); %#ok<ASGLU>
                if exitflag == -3
                    exitflag = 1;
                end
            case 'fsolve'
                [z,fval,exitflag] = ...
                    fsolve(@doObjFunc,z0,Opt.optimset); %#ok<ASGLU>
                if exitflag == -3
                    exitflag = 1;
                end
        end
        
        z(abs(z) <= Opt.optimset.TolX) = 0;
        x(xi) = z(1:nxi);
        dx(dxi) = z(nxi+1:end);
        thissuccess = ~any(isnan(z)) && double(exitflag) > 0;
        Success(iAlt) = Success(iAlt) && thissuccess;
    end

    % TODO: Report more details on which equations and which variables failed.
    if Opt.warning && ~Success(iAlt)
        utils.warning('model', ...
            'Steady state inaccurate or not returned for some variables.');
    end
    
    x(This.log) = exp(x(This.log));
    dx(This.log) = exp(dx(This.log));
    This.Assign(1,:,iAlt) = x + 1i*dx;
    
    % Store the current values to initialise the next parameterisation.
    x0 = x;
    dx0 = dx;
    
end

doRefresh();

% Nested functions.

%**************************************************************************
    function doRefresh()
        if ~isempty(This.Refresh) && Opt.refresh
            This = refresh(This);
        end
    end % doRefresh();

%**************************************************************************
    function y = doObjFunc(p)
        % doobjfunc  This is the objective function for the solver. Evaluate the
        % equations twice, at time t and t+10.
       
        % Split the vector of unknows into levels and growth rates; `nxi` is the
        % number of levels.
        x(xi) = p(1:nxi);
        dx(dxi) = p(nxi+1:end);
        
        % Refresh all dynamic links.
        if ~isempty(This.Refresh)
            doRefresh();
        end
        
        if any(dxi)
            % Some growth rates need to be calculated. Evaluate the model equations at
            % time t and t+10 if at least one growth rate is needed.
            x1 = x + 10*dx;
            y = [f(x,dx);f(x1,dx)];
        else
            % Only levels need to be calculated. Evaluate the model equations at time
            % t.
            y = f(x,dx);
        end
        
        function doRefresh()
            % dorefresh  Refresh dynamic links in each iteration.
            x(This.log) = exp(x(This.log));
            dx(This.log) = exp(dx(This.log));
            This.Assign(1,:,iAlt) = x + 1i*dx;
            This = refresh(This,iAlt);
            x = real(This.Assign(1,:,iAlt));
            dx = imag(This.Assign(1,:,iAlt));
            dx(dx == 0 & This.log) = 1;
            x(This.log) = log(x(This.log));
            dx(This.log) = log(dx(This.log));
        end
        % dorefresh().
        
    end % doObjFunc(),

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
    end % dochkfornans().

end
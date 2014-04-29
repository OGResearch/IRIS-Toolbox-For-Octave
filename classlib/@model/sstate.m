function [This,Flag,NPath,EigVal] = sstate(This,varargin)
% sstate  Compute steady state or balance-growth path of the model.
%
% Syntax
% =======
%
%     M = sstate(M,...)
%
% Input arguments
% ================
%
% * `M` [ model ] - Parameterised model object.
%
% Output arguments
% =================
%
% * `M` [ model ] - Model object with newly computed steady state assigned.
%
% Options
% ========
%
% * `'linear='` [ *`'auto'`* | `true` | `false` ] - Solve for steady state
% using a linear approach, i.e. based on the first-order solution matrices
% and the vector of constants.
% 
% * `'warning='` [ *`true`* | `false` ] - Display IRIS warning produced by
% this function.
%
% Options for non-linear models
% ------------------------------
%
% * `'blocks='` [ `true` | *`false`* ] - Re-arrarnge steady-state equations in
% recursive blocks before computing steady state.
%
% * `'display='` [ *`'iter'`* | `'final'` | `'notify'` | `'off'` ] - Level
% of screen output, see Optim Tbx.
%
% * `'endogenise='` [ cellstr | char | *empty* ] - List of parameters that
% will be endogenised when computing the steady state; the number of
% endogenised parameters must match the number of transtion
% variables exogenised in the `'exogenised='` option.
%
% * `'exogenise='` [ cellstr | char | *empty* ] - List of transition
% variables that will be exogenised when computing the steady state; the
% number of exogenised variables must match the number of parameters
% exogenised in the `'exogenise='` option.
%
% * `'fix='` [ cellstr | *empty* ] - List of variables whose steady state
% will not be computed and kept fixed to the currently assigned values.
%
% * `'fixAllBut='` [ cellstr | *empty* ] - Inverse list of variables whose
% steady state will not be computed and kept fixed to the currently
% assigned values.
%
% * `'fixGrowth='` [ cellstr | *empty* ] - List of variables whose
% steady-state growth will not be computed and kept fixed to the currently
% assigned values.
%
% * `'fixGrowthAllBut='` [ cellstr | *empty* ] - Inverse list of variables
% whose steady-state growth will not be computed and kept fixed to the
% currently assigned values.
%
% * `'fixLevel='` [ cellstr | *empty* ] - List of variables whose
% steady-state levels will not be computed and kept fixed to the currently
% assigned values.
%
% * `'fixLevelAllBut='` [ cellstr | *empty* ] - Inverse list of variables
% whose steady-state levels will not be computed and kept fixed to the
% currently assigned values.
%
% * `'growth='` [ `true` | *`false`* ] - If `true`, both the steady-state levels
% and growth rates will be computed; if `false`, only the levels will be
% computed assuming that the model is either stationary or that the
% correct steady-state growth rates are already assigned in the model
% object.
%
% * `'optimSet='` [ cell | *empty* ] - Name-value pairs with Optim Tbx
% settings; see `help optimset` for details on these settings.
%
% * `'refresh='` [ *`true`* | `false` ] - Refresh dynamic links after steady
% state is computed.
%
% * `'reuse='` [ `true` | *`false`* ] - Reuse the steady-state values
% calculated for a parameterisation to initialise the next
% parameterisation.
%
% * `'solver='` [ `'fsolve'` | *`'lsqnonlin'`* ] - Solver function used to solve
% for the steady state of non-linear models; it can be either of the two
% Optimization Tbx functions, or a user-supplied solver.
%
% * `'sstate='` [ `true` | *`false`* | cell ] - If `true` or a cell array, the
% steady state is re-computed in each iteration; the cell array can be used
% to modify the default options with which the `sstate` function is called.
%
% Options for linear models
% --------------------------
%
% * `'refresh='` [ *`true`* | `false` ] - Refresh dynamic links before steady
% state is computed.
%
% * `'solve='` [ `true` | *`false`* ] - Solve model before computing steady
% state.
%
% Description
% ============
%
% Note that for backward compatibility, the option `'growth='` is set to
% `false` by default so that either the model is assumed stationary or the
% steady-state growth rates have been already pre-assigned to the model
% object. To use the `sstate` function for computing both the steady-state
% levels and steady-state growth rates in a balanced-growth model, you need
% to set the option `'growth=' true`.
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

% Parse options.
[opt,varargin] = passvalopt('model.sstate',varargin{:});

if ischar(opt.linear) && strcmpi(opt.linear,'auto')
    changeLinear = false;
else
    changeLinear = This.linear ~= opt.linear;
    if changeLinear
        wasLinear = This.linear;
        This.linear = opt.linear;
    end
end

%--------------------------------------------------------------------------

% Pre-process options passed to `mysstatenonlin`.
sstateOpt = mysstateopt(This,'verbose',varargin{:});
opt.solve = mysolveopt(This,'verbose',opt.solve);

if ~This.linear
    
    % Non-linear models
    %-------------------
    % Throw a warning if some parameters are NaN.
    chk(This,Inf,'parameters');
    This = mysstatenonlin(This,sstateOpt);

else
    
    % Linear models
    %---------------
    if ~isequal(opt.solve,false)
        % Solve the model first if requested by the user.
        [This,NPath,EigVal] = solve(This,opt.solve);
    end
    [This,Flag] = mysstatelinear(This,sstateOpt);

end

if changeLinear
    This.linear = wasLinear;
end

end
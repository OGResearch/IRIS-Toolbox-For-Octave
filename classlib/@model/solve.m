function [This,NPath,EigVal] = solve(This,varargin)
% solve  Calculate first-order accurate solution of the model.
%
% Syntax
% =======
%
%     M = solve(M,...)
%
% Input arguments
% ================
%
% * `M` [ model ] - Paramterised model object. Non-linear models must also
% have a steady state values assigned.
%
% Output arguments
% =================
%
% * `M` [ model ] - Model with newly computed solution.
%
% Options
% ========
%
% * `'expand='` [ numeric | *`0`* | `NaN` ] - Number of periods ahead up to
% which the model solution will be expanded; if `NaN` the matrices needed
% to support solution expansion are not calculated and stored at all and
% the model cannot be used later in simulations or forecasts with
% anticipated shocks or plans.
%
% * `'error='` [ `true` | *`false`* ] - Throw an error if no unique stable
% solution exists; if `false`, a warning message only will be displayed.
%
% * `'linear='` [ *`'auto'`* | `true` | `false` ] - Solve the model using a
% linear approach, i.e. differentiating around zero and not the currently
% assigned steady state.
%
% * `'progress='` [ `true` | *`false`* ] - Display progress bar in the
% command window.
%
% * `'refresh='` [ *`true`* | `false` ] - Refresh dynamic links before
% computing the solution.
%
% * `'select='` [ *`true`* | `false` ] - Automatically detect which
% equations need to be re-differentiated based on parameter changes from
% the last time the system matrices were calculated.
%
% * `'warning='` [ *`true`* | `false` ] - Display warnings produced by this
% function.
%
% Description
% ============
%
% The IRIS solver uses an ordered QZ (or generalised Schur) decomposition
% to integrate out future expectations. The QZ may (very rarely) fail for
% numerical reasons. IRIS  includes two patches to handle the some of the
% QZ failures: a SEVN2 patch (Sum-of-EigenValues-Near-Two), and an E2C2S
% patch (Eigenvalues-Too-Close-To-Swap).
%
% * The SEVN2 patch: The model contains two or more unit roots, and the QZ
% algorithm interprets some of them incorrectly as pairs of eigenvalues
% that sum up accurately to 2, but with one of them significantly below 1
% and the other significantly above 1. IRIS replaces the entries on the
% diagonal of one of the QZ factor matrices with numbers that evaluate to
% two unit roots.
%
% * The E2C2S patch: The re-ordering of thq QZ matrices fails with a
% warning `'Reordering failed because some eigenvalues are too close to
% swap.'` IRIS attempts to re-order the equations until QZ works. The
% number of attempts is limited to `N-1` at most where `N` is the total
% number of equations.
%
% Example
% ========
%

% -IRIS Toolbox. 2008/10/20.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

opt = passvalopt('model.solve',varargin{1:end});

% Backward compatibility.
if opt.forward > 0 && opt.expand == 0
    opt.expand = opt.forward;
end

if ischar(opt.linear) && strcmpi(opt.linear,'auto')
    opt.linear = This.linear;
elseif opt.linear ~= This.linear
    opt.select = false;
end

%--------------------------------------------------------------------------

% Refresh dynamic links.
if opt.refresh && ~isempty(This.Refresh)
    This = refresh(This);
end

if opt.warning
    % Warning if some log-lin variables have non-positive steady state.
    chk(This,Inf,'parameters','log');
end

% Calculate solutions for all parameterisations, and store expansion
% matrices.
expMatrices = true;
[This,NPath,nanDeriv,sing2] = mysolve(This,Inf,opt,expMatrices);

if (opt.warning || opt.error) && any(NPath ~= 1) && iswarning('model')
    doErrorWarning();
end

if nargout > 2
    EigVal = This.eigval;
end

% Nested functions.

%**************************************************************************
    function doErrorWarning()
        if opt.error
            func = @utils.error;
        else
            func = @utils.warning;
        end
        [body,args] = mysolvefail(This,NPath,nanDeriv,sing2);
        func('model',body,args{:});
    end % doErrorWarning().

end
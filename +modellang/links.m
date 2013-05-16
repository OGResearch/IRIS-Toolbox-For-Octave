% !links  Define dynamic links.
%
% Syntax
% =======
%
%     !links
%        PARAMETER_NAME := EXPR;
%        VARIABLE_NAME := EXPR;
%
% Syntax with equation labels
% ============================
%
%     !links
%        'Equation label' PARAMETER_NAME := EXPR;
%        'Equation label' VARIABLE_NAME := EXPR;
%
% Description
% ============
%
% The dynamic links relate a particular parameter (or steady-state value)
% on the LHS to a function of other parameters or steady-state values on
% the RHS. `EXPR` can be any expression involving parameter names,
% variables names, Matlab functions and constants, or your own m-file
% functions on the path; it must not refer to any lags or leads.
% `EXPR` must evaluate to a single number. It is the user's
% responsibility to properly handle the imaginary (i.e. growth) part of the
% steady-state values.
%
% The links are automatically refreshed in [`solve`](model/solve),
% [`sstate`](model/sstate), and [`chksstate`](model/chksstate) functions,
% and also in each iteration within the [`estimate`](model/estimate)
% function. They can also be refreshed manually by calling
% [`refresh`](model/refresh).
%
% The links must not involve parameters occuring in
% [`!dtrends`](modellang/dtrends) equations that will be estimated using
% the `'outoflik='` option of the [`estimate`](model/estimate) function.
%
% Example
% ========
%
%     !links
%        R := 1/beta;
%        alphak := 1 - alphan - alpham;


% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

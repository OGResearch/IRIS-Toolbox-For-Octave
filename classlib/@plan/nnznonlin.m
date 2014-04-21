function N = nnznonlin(This)
% nnznonlin  Number of non-linearised data points.
%
% Syntax
% =======
%
%     N = nnznonlin(P)
%
% Input arguments
% ================
%
% * `P` [ plan ] - Simulation plan.
%
% Output arguments
% =================
%
% * `N` [ numeric ] - Number of non-linearised equations.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

N = nnz(This.qAnchors);

end

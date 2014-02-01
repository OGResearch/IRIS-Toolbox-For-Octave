function n = nnzexog(this)
% nnzexog  Number of exogenised data points.
%
% Syntax
% =======
%
%     N = nnzexog(P)
%
% Input arguments
% ================
%
% * `P` [ plan ] - Simulation plan.
%
% Output arguments
% =================
%
% * `N` [ numeric ] - Number of exogenised data points; each variable at
% each date counts as one data point.
%
% Description
% ============
%
% Example
% ========

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%**************************************************************************

n = nnz(this.xAnchors);

end

function n = nnzcond(this)
% nnzcond  Number of conditioning data points.
%
% Syntax
% =======
%
%     N = nnzcond(P)
%
% Input arguments
% ================
%
% * `P` [ plan ] - Simulation plan.
%
% Output arguments
% =================
%
% * `N` [ numeric ] - Number of conditioning data points; each variable at
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

n = nnz(this.CAnch);

end

function [n,nreal,nimag] = nnzendog(this)
% nnzendog  Number of endogenised data points.
%
% Syntax
% =======
%
%     [N,NREAL,NIMAG] = nnzendog(P)
%
% Input arguments
% ================
%
% * `P` [ plan ] - Simulation plan.
%
% Output arguments
% =================
%
% * `N` [ numeric ] - Total number of endogenised data points; each shock
% at each time counts as one data point.
%
% * `NREAL` [ numeric ] - Number of endogenised data points with
% anticipation mode 1.
%
% * `NIMAG` [ numeric ] - Number of endogenised data points with
% anticipation mode 1i.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%**************************************************************************

nreal = nnz(this.NAnchReal);
nimag = nnz(this.NAnchImag); 
n = nreal + nimag;

end

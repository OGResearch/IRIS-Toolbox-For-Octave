function [B,BStd,E,EStd,YFit,Range,BCov] = regress(Y,X,Range,varargin)
% regress  Ordinary or weighted least-square regression.
%
% Syntax
% =======
%
%     [B,BStd,E,EStd,YFit,Range,BCov] = regress(Y,X)
%     [B,BStd,E,EStd,YFit,Range,BCov] = regress(Y,X,Range,...)
%
% Input arguments
% ================
%
% * `Y` [ tseries ] - Tseries object with independent (LHS) variables.
%
% * `X` [ tseries] - Tseries object with regressors (RHS) variables.
%
% * `Range` [ numeric ] - Date range on which the regression will be run;
% if not specified, the entire range available will be used.
%
% Output arguments
% =================
%
% * `B` [ numeric ] - Vector of estimated regression coefficients.
%
% * `BStd` [ numeric ] - Vector of std errors of the estimates.
%
% * `E` [ tseries ] - Tseries object with the regression residuals.
%
% * `EStd` [ numeric ] - Estimate of the std deviation of the regression
% residuals.
%
% * `YFit` [ tseries ] - Tseries object with fitted LHS variables.
%
% * `Range` [ numeric ] - The actually used date range.
%
% * `bBCov` [ numeric ] - Covariance matrix of the coefficient estimates.
%
% Options
% ========
%
% * `'constant='` [ `true` | *`false`* ] - Include a constant vector in the
% regression; if true the constant will be placed last in the matrix of
% regressors.
%
% * `'weighting='` [ tseries | *empty* ] - Tseries object with weights on
% the observations in the individual periods.
%
% Description
% ============
%
% This function calls the built-in `lscov` function.
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

if nargin < 3
   Range = Inf;
end

% Parse input arguments.
pp = inputParser();
pp = pp.addRequired('y',@istseries);
pp = pp.addRequired('x',@istseries);
pp = pp.addRequired('range',@isnumeric);
pp = pp.parse(Y,X,Range);

% Parse options.
opt = passvalopt('tseries.regress',varargin{:});

%--------------------------------------------------------------------------

if length(Range) == 1 && isinf(Range)
   Range = get([X,Y],'minrange');
else
   Range = Range(1) : Range(end);
end

xData = rangedata(X,Range);
ydata = rangedata(Y,Range);
if opt.constant
   xData(:,end+1) = 1;
end

if isempty(opt.weighting)
   [B,BStd,eVar,BCov] = lscov(xData,ydata);
else
   w = rangedata(opt.weighting,Range);
   [B,BStd,eVar,BCov] = lscov(xData,ydata,w);
end
EStd = sqrt(eVar);

if nargout > 2
   E = replace(Y,ydata - xData*B,Range(1));
end

if nargout > 4
   YFit = replace(Y,xData*B,Range(1));
end

end

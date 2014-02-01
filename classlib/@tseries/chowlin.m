function [y2,b,rho,u1,u2] = chowlin(y1,x2,range,varargin)
% chowlin  Chow-Lin distribution of low-frequency observations over higher-frequency periods.
%
% Syntax
% =======
%
%     [Y2,B,RHO,U1,U2] = chowlin(Y1,X2)
%     [Y2,B,RHO,U1,U2] = chowlin(Y1,X2,range,...)
%
% Input arguments
% ================
%
% * `Y1` [ tseries ] - Low-frequency input tseries object that will be
% distributed over higher-frequency observations.
%
% * `X2` [ tseries ] - Tseries object with regressors used to distribute
% the input data.
%
% * `range` [ numeric ] - Low-frequency date range on which the
% distribution will be computed.
%
% Output arguments
% =================
%
% * `Y2` [ tseries ] - Output data distributed with higher frequency.
%
% * `B` [ numeric ] - Vector of regression coefficients.
%
% * `RHO` [ numeric ] - Actually used autocorrelation coefficient in the
% residuals.
%
% * `U1` [ tseries ] - Low-frequency regression residuals.
%
% * `U2` [ tseries ] - Higher-frequency regression residuals.
%
% Options
% ========
%
% * `'constant='` [ *`true`* | `false` ] - Include a constant term in the
% regression.
%
% * `'log='` [ `true` | *`false`* ] - Logarithmise the data before distribution,
% de-logarithmise afterwards.
%
% * `'ngrid='` [ numeric | *`200`* ] - Number of grid search points for
% finding autocorrelation coefficient for higher-frequency residuals.
%
% * `'rho='` [ *`'estimate'`* | `'positive'` | `'negative'` | numeric ] -
% How to determine the autocorrelation coefficient for higher-frequency
% residuals.
%
% * `'timeTrend='` [ `true` | *`false`* ] - Include a time trend in the
% regression.
%
% Description
% ============
%
% Chow,G.C., and A.Lin (1971). Best Linear Unbiased Interpolation,
% Distribution and Extrapolation of Time Series by Related Times Series.
% Review of Economics and Statistics, 53, pp. 372-75.
%
% See also Appendix 2 in
% Robertson, J.C., and E.W.Tallman (1999). Vector Autoregressions:
% Forecasting and Reality. FRB Atlanta Economic Review, 1st Quarter 1999,
% pp.4-17.
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

if nargin < 3
   range = Inf;
end

options = passvalopt('tseries.chowlin',varargin{:});

%**************************************************************************

f1 = get(y1,'freq');
if is.numericscalar(x2)
   f2 = x2;
   x2 = [];
else
   f2 = get(x2,'freq');
end

if f2 <= f1
   error('iris:tseries',[ ...
      'Explanatory variables must have higher frequency ', ...
      'than the explained variable.']);
end

% Number of high-frequency periods within a low-frequency period. Must be
% an integer.
g = f2 / f1;
if g ~= round(g)
   error('iris:tseris', ...
      'High frequency must be a multiple of low frequency.');
end

% Get low-frequency LHS observations.
[y1data,range1] = rangedata(y1,range);
if options.log
   y1data = log(y1data);
end
nper1 = length(range1);

% Set up High-frequency range.
start2 = convert(range1(1),f2,'standinMonth','first');
end2 = convert(range1(end),f2,'standinMonth','last');
range2 = start2 : end2;
nper2 = length(range2);

% Aggregation matrix.
c = ones([1,g]) / g;
C = kron(eye(nper1),c);

% Convert high-frequency explanatory variables to low frequency by
% averaging.
if ~isempty(x2)
   x2data = rangedata(x2,range2);
   if options.log
      x2data = log(x2data);
   end
   nx = size(x2data,2);
   x1data = nan([nper1,nx]);
   for i = 1 : nx
      tmp = reshape(x2data(:,i),[g,nper1]);
      tmp = c*tmp;
      x1data(:,i) = tmp(:);
   end
end

% Set-up RHS matrix.
M1 = [];
M2 = [];
if options.constant
   M1 = [M1,ones([nper1,1])];
   M2 = ones([nper2,1]);
end
if options.timetrend
   t2 = (1 : nper2)';
   t1 = C*t2;
   M1 = [M1,t1];
   M2 = [M2,t2];
end
if ~isempty(x2)
   M1 = [M1,x1data];
   M2 = [M2,x2data];
end

if isempty(M1)
   error('iris:tseries',[ ...
      'No left-hand-side regressor specified.']);
end

% Run regression and compute autocorrelation of residuals.
sample1 = all(~isnan([M1,y1data]),2);
b = M1(sample1,:) \ y1data(sample1);
tmp = y1data(sample1) - M1(sample1,:)*b;
rho1 = tmp(1:end-1) \ tmp(2:end);
u1data = nan(size(y1data));
u1data(sample1) = tmp;

% Project high-frequency explanatory variables.
sample2 = all(~isnan(M2),2);
y2data = M2*b;

% Correct for residuals.
if any(strcmpi(options.rho,{'auto','estimate','positive','negative'}))
   % Determine high-frequency autocorrelation consistent with estimated
   % low-frequency autocorrelation.
   rho2 = xxautocorr(rho1,f1,f2,options.ngrid);
   % Set rho2 to zero if it's estimate is negative and the user restricted
   % the estimated value to be positive or vice versa.
   if (strcmpi(options.rho,'positive') && rho2 < 0) ...
         || (strcmpi(options.rho,'negative') && rho2 > 0)
      rho2 = 0;
   end
else
   rho2 = options.rho;
end
tmp = u1data;
tmp(~sample1) = 0;
if rho2 ~= 0
   P2 = toeplitz(rho2.^(0 : nper2-1));
   u2data = P2*C'*((C*P2*C')\tmp);
else
   u2data = C'*((C*C')\tmp);
end
u2data(~sample2) = NaN;
y2data = y2data + u2data;

% Output data.
if options.log
   u1data = exp(u1data);
   y2data = exp(y2data);
   u2data = exp(u2data);
end
u1 = replace(y1,u1data,range1(1));
y2 = replace(y1,y2data,range2(1));
u2 = replace(y1,u2data,range2(1));
rho = [rho1,rho2];

end

% Subfunctions.

%**************************************************************************
function rho2 = xxautocorr(rho1,f1,f2,ngrid)
% xxautocorr  Use a simple grid search to find high-frequency
% autocorrelation coeeficient corresponding to the estimated low-frequency
% one.
g = f2 / f1;
C = blkdiag(ones([1,g]),ones([1,g]))/g;
rho2s = linspace(-1,1,ngrid+2);
rho2s = rho2s(2:end-1);
rho1s = nan(size(rho2s));
for i = 1 : numel(rho2s)
   rho1s(i) = dotry(rho2s(i));
end
[~,index] = min(abs(rho1s - rho1));
rho2 = rho2s(index);

   function rho1 = dotry(rho2)
      P2 = toeplitz(rho2.^(0:2*g-1));
      P1 = C*P2*C';
      rho1 = P1(2,1) / P1(1,1);
   end

end
% xxautocorr().
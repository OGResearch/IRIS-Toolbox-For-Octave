function F = beta(Mean,Std)
% beta  Create function proportional to log of beta distribution.
%
% Syntax
% =======
%
%     F = logdist.beta(Mean,Std)
%
% Input arguments
% ================
%
% * `Mean` [ numeric ] - Mean of the beta distribution.
%
% * `Std` [ numeric ] - Std dev of the beta distribution.
%
% Output arguments
% =================
%
% * `F` [ function_handle ] - Function handle returning a value
% proportional to the log of the beta density.
%
% Description
% ============
%
% See [help on the logdisk package](logdist/Contents) for details on
% using the function handle `F`.
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

a = (1-Mean)*Mean^2/Std^2 - Mean;
b = a*(1/Mean - 1);
if a > 1 && b > 1
    mode = (a - 1)/(a + b - 2);
else
    mode = NaN;
end
F = @(x,varargin) xxBeta(x,a,b,Mean,Std,mode,varargin{:});

end

% Subfunctions.

%**************************************************************************
function Y = xxBeta(X,A,B,Mean,Std,Mode,varargin)

Y = zeros(size(X));
inx = X > 0 & X < 1;
X = X(inx);
if isempty(varargin)
    Y(inx) = (A-1)*log(X) + (B-1)*log(1-X);
    Y(~inx) = -Inf;
    return
end

switch lower(varargin{1})
    case {'proper','pdf'}
        Y(inx) = X.^(A-1).*(1-X).^(B-1)/beta(A,B);
    case 'info'
        Y(inx) = -(B - 1)./(X - 1).^2 - (A - 1)./X.^2;
    case {'a','location'}
        Y = A;
    case {'b','scale'}
        Y = B;
    case 'mean'
        Y = Mean;
    case {'sigma','sgm','std'}
        Y = Std;
    case 'mode'
        Y = Mode;
    case 'name'
        Y = 'beta';
    case 'draw'
        Y = betarnd(A,B,varargin{2:end});
end

end % xxBeta().
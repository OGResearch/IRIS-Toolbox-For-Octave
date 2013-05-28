function F = gamma(Mean,Std)
% gamma  Create function proportional to log of gamma distribution.
%
% Syntax
% =======
%
%     F = logdist.gamma(Mean,Std)
%
% Input arguments
% ================
%
% * `Mean` [ numeric ] - Mean of the gamma distribution.
%
% * `Std` [ numeric ] - Std dev of the gamma distribution.
%
% Output arguments
% =================
%
% * `F` [ function_handle ] - Function handle returning a value
% proportional to the log of the gamma density.
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

b = Std^2/Mean;
a = Mean/b;
if a >= 1
    mode = (a - 1)*b;
else
    mode = NaN;
end
F = @(x,varargin) xxGamma(x,a,b,Mean,Std,mode,varargin{:});

end

% Subfunctions.

%**************************************************************************
function Y = xxGamma(X,A,B,Mean,Std,Mode,varargin)

Y = zeros(size(X));
inx = X > 0;
X = X(inx);
if isempty(varargin)
    Y(inx) = (A-1)*log(X) - X/B;
    Y(~inx) = -Inf;
    return
end

switch lower(varargin{1})
    case {'proper','pdf'}
        Y(inx) = X.^(A-1).*exp(-X/B)/(B^A*gamma(A));
    case 'info'
        Y(inx) = -(A - 1)/X.^2;
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
        Y = 'gamma';
    case 'draw'
        Y = gamrnd(A,B,varargin{2:end});
end

end % xxGamma().
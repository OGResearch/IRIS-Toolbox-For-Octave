function Y = xxGamma(X,A,B,Mean,Std,Mode,varargin)
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

% A: shape
% B: scale

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
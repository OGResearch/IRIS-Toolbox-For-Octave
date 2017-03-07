function F = lognormal(Mean,Std)
% lognormal  Create function proportional to log of log-normal distribution.
%
% Syntax
% =======
%
%     F = logdist.lognormal(Mean,Std)
%
% Input arguments
% ================
%
% * `Mean` [ numeric ] - Mean of the log-normal distribution.
%
% * `Std` [ numeric ] - Std dev of the log-normal distribution.
%
% Output arguments
% =================
%
% * `F` [ function_handle ] - Function handle returning a value
% proportional to the log of the log-normal density.
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
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

a = log(Mean^2/sqrt(Std^2 + Mean^2));
b = sqrt(log(Std^2/Mean^2 + 1));
mode = exp(a - b^2);
F = @(x,varargin) xxLogNormal(x,a,b,Mean,Std,mode,varargin{:});

end

% Subfunctions.

%**************************************************************************
function Y = xxLogNormal(X,A,B,Mean,Std,Mode,varargin)

Y = zeros(size(X));
inx = X > 0;
X = X(inx);
if isempty(varargin)
    logx = log(X);
    Y(inx) = -0.5 * ((logx - A)./B).^2  - logx;
    Y(~inx) = -Inf;
    return
end

switch lower(varargin{1})
    case {'proper','pdf'}
        Y(inx) = ...
            1/(B*sqrt(2*pi)) .* exp(-(log(X)-A).^2/(2*B^2)) ./ X;
    case 'info'
        Y(inx) = (B^2 + A - log(X) + 1)./(B^2*X.^2);
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
        Y = 'lognormal';
    case 'draw'
        Y = exp(A + B*randn(varargin{2:end}));
end

end % xxLogNormal().
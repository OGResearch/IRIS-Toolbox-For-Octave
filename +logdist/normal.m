function F = normal(Mean,Std)
% normal  Create function proportional to log of normal distribution.
%
% Syntax
% =======
%
%     F = logdist.normal(Mean,Std)
%
% Input arguments
% ================
%
% * `Mean` [ numeric ] - Mean of the normal distribution.
%
% * `Std` [ numeric ] - Std dev of the normal distribution.
%
% Output arguments
% =================
%
% * `F` [ function_handle ] - Function handle returning a value
% proportional to the log of the normal density.
%
% Description
% ============
%
% See [help on the logdisk package](logdist/Contents) for details on using
% the function handle `F`.
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

a = Mean;
b = Std;
mode = Mean;
F = @(x,varargin) xxNormal(x,a,b,Mean,Std,mode,varargin{:});

end

% Subfunctions.

%**************************************************************************
function Y = xxNormal(X,A,B,Mu,Std,Mode,varargin)

if isempty(varargin)
    Y = -0.5 * ((X - Mu)./Std).^2;
    return
end

switch lower(varargin{1})
    case {'proper','pdf'}
        Y = 1/(Std*sqrt(2*pi)) .* exp(-(X-Mu).^2/(2*Std^2));
    case 'info'
        Y = 1/(Std^2)*ones(size(X));
    case {'a','location'}
        Y = A;
    case {'b','scale'}
        Y = B;
    case 'mean'
        Y = Mu;
    case {'sigma','sgm','std'}
        Y = Std;
    case 'mode'
        Y = Mode;
    case 'name'
        Y = 'normal';
    case 'draw'
        Y = Mu + Std*randn(varargin{2:end});
end

end % xxNormal().
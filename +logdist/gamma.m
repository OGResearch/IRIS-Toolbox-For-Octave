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
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

b = Std^2/Mean;
a = Mean/b;
if a >= 1
    mode = (a - 1)*b;
else
    mode = NaN;
end
F = @(x,varargin) logdist.mygamma(x,a,b,Mean,Std,mode,varargin{:});

end

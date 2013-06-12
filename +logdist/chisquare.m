function F = chisquare(Df)
% gamma  Create function proportional to log of Chi-Squared distribution.
%
% Syntax
% =======
%
%     F = logdist.chisquare(Mean,Std)
%
% Input arguments
% ================
%
% * `Df` [ integer ] - Degrees of freedom of Chi-squared distribution.
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

a = Df / 2 ;
b = 2 ;
Mean = a*b ;
Std = sqrt(a)*b ;
if a >= 1
    mode = (a - 1)*b;
else
    mode = NaN;
end
F = @(x,varargin) logdist.mygamma(x,a,b,Mean,Std,mode,varargin{:});

end
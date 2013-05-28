function F = uniform(Lo,Hi)
% uniform  Create function proportional to log of uniform distribution.
%
% Syntax
% =======
%
%     F = logdist.uniform(Lo,Hi)
%
% Input arguments
% ================
%
% * `Lo` [ numeric ] - Lower bound of the uniform distribution.
%
% * `Hi` [ numeric ] - Upper bound of the uniform distribution.
%
% Output arguments
% =================
%
% * `F` [ function_handle ] - Handle to a function returning a value that
% is proportional to the log of the uniform density.
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

if Lo > Hi
    [Lo,Hi] = deal(Hi,Lo);
end

mu = 1/2*(Lo + Hi);
sgm = sqrt(1/12*(Hi - Lo)^2);
mode = mu;

F = @(x,varargin) xxUniform(x,Lo,Hi,mu,sgm,mode,varargin{:});

end

% Subfunctions.

%**************************************************************************
function Y = xxUniform(X,A,B,Mu,Sgm,Mode,varargin)

Y = zeros(size(X));
index = X >= A & X <= B;
Y(~index) = -Inf;
if isempty(varargin)
    return
end

switch lower(varargin{1})
    case {'proper','pdf'}
        Y(index) = 1/(B - A);
        Y(~index) = 0;
    case 'info'
        Y = 0;
    case {'a','location'}
        Y = A;
    case {'b','scale'}
        Y = B;
    case 'mean'
        Y = Mu;
    case {'sigma','sgm','std'}
        Y = Sgm;
    case 'mode'
        Y = Mode;
    case 'name'
        Y = 'uniform';
    case 'draw'
        Y = A + (B-A)*rand(varargin{2:end});
end

end % xxUniform().
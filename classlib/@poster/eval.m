function varargout = eval(This,varargin)
% eval  Evaluate posterior density at specified points.
%
% Syntax
% =======
%
%     [X,L,PP,SrfP,FrfP] = eval(Pos)
%     [X,L,PP,SrfP,FrfP] = eval(Pos,P)
%
% Input arguments
% ================
%
% * `Pos` [ poster ] - Posterior object returned by the
% [`model/estimate`](model/estimate) function.
%
% * `P` [ struct ] - Struct with parameter values at which the posterior
% density will be evaluated; if `P` is not specified, the posterior density
% at the point of the estimated mode is returned.
%
% Output arguments
% =================
%
% * `X` [ numeric ] - The value of log posterior density evaluated at `P`;
% N.B. the returned value is log posterior, and not minus log posterior.
%
% * `L` [ numeric ] - Contribution of data likelihood to log posterior.
%
% * `PP` [ numeric ] - Contribution of parameter priors to log posterior.
%
% * `SrfP` [ numeric ] - Contribution of shock response function priors to
% log posterior.
%
% * `FrfP` [ numeric ] - Contribution of frequency response function priors
% to log posterior.
%
% Description
% ============
%
% The total log posterior consists, in general, of the four contributions
% listed above:
%
%     X = L + PP + SrfP + FrfP.
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

if isempty(varargin)
    p = This.initParam;
elseif length(varargin) == 1
    p = varargin{1};
else
    p = varargin;
end

%--------------------------------------------------------------------------

if nargin == 1 && nargout <= 1
    % Return log posterior at optimum.
    varargout{1} = This.initLogPost;
else
    % Evaluate log poeterior at specified parameter sets. If
    % it's multiple parameter sets, pass them in as a cell, not
    % as multiple input arguments.
    if isstruct(p)
        s = p;
        nPar = length(This.paramList);
        p = nan(1,nPar);
        for i = 1 : nPar
            p(i) = s.(This.paramList{i});
        end
    end
    [varargout{1:nargout}] = mysimulate(This,'eval',p);
end

end
function [Obj,V,Est,PEst] = oolik(L0,L1,L2,L3,NObs,Opt)
% oolik  [Not a public function] Estimate out-of-lik parameters and sum up log-likelihood function components.
%
% Backed IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%#ok<*CTCH>
 
try
    Opt.objfunc;
catch
    Opt.objfunc = 1;
end

%--------------------------------------------------------------------------

% L0 := sum log det F;
% L1 := sum pe Fi pe;
% L2 := sum Mt Fi M;
% L3 := sum Mt Fi pe;

% Estimate user-requested out-of-lik parameters.
if ~isempty(L2) && ~isempty(L3)
    L2i = pinv(L2);
    Est = L2i * L3;
    PEst = L2i;
    % Correct likelihood for estimated parameters.
    L1 = L1 - Est.'*L3;
else
    Est = zeros(0,1);
    PEst = zeros(0);
end

% Estimate common variance factor.
V = 1;
if Opt.relative && Opt.objfunc == 1
    if NObs > 0
        V = L1 / NObs;
        L0 = L0 + NObs*log(V);
        L1 = L1 / V;
    else
        L1 = 0;
    end
end

% Put together objective function.
if Opt.objfunc == 1
    % Minus log likelihood.
    Obj = (NObs*log(2*pi) + L0 + L1) / 2;
else
    % Weighted prediction errors.
    Obj = L1 / 2;
end

end
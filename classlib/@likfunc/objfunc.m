function [Obj,Lik,PP,SP] = objfunc(P,This,D,Pri,EstOpt,~)
% objfunc  [Not a public function] Evaluate minus log posterior.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.
    
%--------------------------------------------------------------------------

Obj = 0; % Minus log posterior.
Lik = 0; % Minus log data likelihood.
PP = 0; % Minus log parameter prior.
SP = 0; % Minus log system prior.

isLik = EstOpt.evallik;
isPPrior = EstOpt.evalpprior && any(Pri.priorindex);

X = D(This.nameType == 1);
P0 = [D{This.nameType == 2}];
P0(Pri.paramPos) = P;

% Evaluate parameter priors.
if isPPrior
    PP = estimateobj.myevalpprior(P0,Pri);
    Obj = Obj + PP;
end

% Evaluate data likelihood.
if isfinite(Obj) && isLik
    % Evaluate minus log likelihood.
    Lik = This.minusLogLikFunc(X,P0);
    % Sum up minus log priors and minus log likelihood.
    Obj = Obj + Lik;
end

if ~isfinite(Obj) || imag(Obj) ~= 0 || length(Obj) ~= 1
    % Although the imag part is zero and causes no problems in
    % Optimization Toolbox or user-supplied optimisation procedure, this
    % will be still caught as a complex number in the posterior simulator
    % indicating that the draw is to be discarded.
    Obj = complex(1e10,0);
end

end
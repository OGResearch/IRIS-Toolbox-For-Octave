function [Obj,Lik,PP,SP] = objfunc(X,This,Data,Pri,EstOpt,LikOpt)
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
isSPrior = EstOpt.evalsprior && ~isempty(Pri.sprior);

% Evaluate parameter priors.
if isPPrior
    PP = estimateobj.myevalpprior(X,Pri);
    Obj = Obj + PP;
end

% Update model with new parameter values; do this before evaluating the
% system priors.
if isLik || isSPrior
    throwErr = strcmpi(EstOpt.nosolution,'error');
    [This,UpdateOk] = myupdatemodel(This,X,Pri,EstOpt,throwErr);
    if ~UpdateOk
        Obj = Inf;
    end
end

% Evaluate system priors.
if isfinite(Obj) && isSPrior
    % The function `evalsystempriors` returns minus log density.
    SP = evalsystempriors(This,Pri.sprior);
    Obj = Obj + SP;
end

% Evaluate data likelihood.
if isfinite(Obj) && isLik
    % Evaluate minus log likelihood; no data output is required.
    Lik = LikOpt.minusLogLikFunc(This,Data,[],LikOpt);
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
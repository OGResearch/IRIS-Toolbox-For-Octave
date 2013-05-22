function [Obj,Lik,PP,SP] = objfunc(X,This,Data,Pri,LikOpt,Opt)
% objfunc  [Not a public function] Evaluate objective function, usually minus log posterior.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.
    
%--------------------------------------------------------------------------

% Minus log posterior.
Obj = 0;

% Minus log data likelihood.
Lik = 0;

% Minus log parameter prior.
PP = 0;

% Minus log system prior.
SP = 0;

isLik = Opt.evallik;
isPPrior = Opt.evalpprior && any(Pri.priorindex);
isSPrior = Opt.evalsprior && ~isempty(Pri.sprior);

% Evaluate parameter priors.
if isPPrior
    PP = 0;
    for i = find(Pri.priorindex)
        PP = PP + Pri.prior{i}(X(i));
        if ~isfinite(PP) || length(PP) ~= 1
            PP = -Inf;
            break
        end
    end
    PP = -PP;
    Obj = Obj + PP;
end

% Update model with new parameter values; do this before evaluating the
% system priors.
if isLik || isSPrior
    throwErr = strcmpi(Opt.nosolution,'error');
    [This,UpdateOk] = myupdatemodel(This,X,Pri,Opt,throwErr);
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
    % Evaluate minus log likelihood. No data output is required.
    if LikOpt.domain == 't'
        Lik = mykalman(This,Data,[],LikOpt);
    else
        Lik = myfdlik(This,Data,[],LikOpt);
    end
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
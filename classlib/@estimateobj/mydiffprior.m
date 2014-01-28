function [PropCov,Hess] ...
    = mydiffprior(This,Data,PStar,Hess,BHit,Pri,EstOpt,LikOpt)
% mydiffprior  [Not a public function] Contributions of priors to Hessian and proposal covariance.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

np = length(Pri.plist);
diagInx = eye(np) == 1;

% Diagonal elements of the varous componenets of the Hessian.
diffObj = zeros(1,np);
diffLik = zeros(1,np);
diffPPrior = zeros(1,np);
diffSPrior = zeros(1,np);

% Differentiation step size.
h = eps()^(1/3)*max(abs(PStar),1);

for ip = 1 : np
    x0 = PStar;
    if BHit(ip) == -1
        % Lower bound hit; move the centre point up.
        x0(ip) = x0(ip) + h(ip);
    elseif BHit(ip) == 1
        % Upper bound hit; move the centre point down.
        x0(ip) = x0(ip) - h(ip);
    end
    xp = x0;
    xm = x0;
    xp(ip) = x0(ip) + h(ip);
    xm(ip) = x0(ip) - h(ip);
    [obj0,l0,p0,s0] = objfunc(x0,This,Data,Pri,EstOpt,LikOpt);
    [objp,lp,pp,sp] = objfunc(xp,This,Data,Pri,EstOpt,LikOpt);
    [objm,lm,pm,sm] = objfunc(xm,This,Data,Pri,EstOpt,LikOpt);
    h2 = h(ip)^2;
    
    % Diff total objective function.
    iDiffObj = (objp - 2*obj0 + objm) / h2;
    if iDiffObj <= 0 || ~isfinite(iDiffObj)
        sgm = 4*max(abs(x0(ip)),1);
        iDiffObj = 1/sgm^2;
    end
    diffObj(ip) = iDiffObj;
    
    % Diff data likelihood.
    if EstOpt.evallik
        diffLik(ip) = (lp - 2*l0 + lm) / h2;
    end
    
    % Diff parameter priors.
    if EstOpt.evalpprior
        iDiffPPrior = (pp - 2*p0 + pm) / h2;
        if ~isempty(Pri.prior{ip}) && is.func(Pri.prior{ip})
            try %#ok<TRYNC>
                iDiffPPrior = Pri.prior{ip}(x0(ip),'info');
            end
        end
        diffPPrior(ip) = iDiffPPrior;
    end
    
    % Diff system priors.
    if EstOpt.evalsprior
        diffSPrior(ip) = (sp - 2*s0 + sm) / h2;
    end
    
end

if isempty(Hess{1})
    Hess{1} = nan(np);
    Hess{1}(diagInx) = diffObj;
end

if EstOpt.evalpprior
    % Parameter priors are independent, the off-diagonal elements can be set to
    % zero.
    Hess{2} = diag(diffPPrior);
else
    Hess{2} = zeros(np);
end

if EstOpt.evalsprior
    Hess{3} = nan(np);
    Hess{3}(diagInx) = diffSPrior;
else
    Hess{3} = zeros(np);
end

% Initial proposal covariance matrix is the diagonal of the Hessian.
PropCov = diag(1./diffObj);

end
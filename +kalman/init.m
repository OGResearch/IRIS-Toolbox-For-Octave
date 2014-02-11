function S = init(S,ILoop,Opt)
% init  [Not a public function] Initialize Kalman filter.
%
% Backed IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

nUnit = S.nunit;
nb = S.nb;
ne = S.ne;
ixStable = [false(1,nUnit),true(1,nb-nUnit)];

% Initialise mean.
S.ainit = zeros(nb,1);
if iscell(Opt.initcond)
    % User-supplied initial condition.
    % Convert Mean[Xb] to Mean[Alpha].
    S.ainit = Opt.initcond{1}(:,1,min(end,ILoop));
    toZero = isnan(S.ainit) & ~S.ixRequired(:);
    S.ainit(toZero) = 0;
    S.ainit = S.U \ S.ainit;
elseif ~isempty(S.ka)
    % Asymptotic initial condition for the stable part of Alpha;
    % the unstable part is kept at zero initially.
    I = eye(nb - nUnit);
    a1 = zeros(nUnit,1);
    a2 = (I - S.Ta(ixStable,ixStable)) \ S.ka(ixStable,1);
    S.ainit = [a1;a2];
end

if nUnit > 0 && isnumeric(Opt.initmeanunit)
    % Initialise mean for unit root processes.
    % Convert Xb to Alpha.
    xbInitMean = Opt.initmeanunit(:,1,min(end,ILoop));
    toZero = isnan(xbInitMean) & ~S.ixRequired(:);
    xbInitMean(toZero) = 0;
    S.ainit(1:nUnit) = S.U(:,1:nUnit) \ xbInitMean; 
end

% Initialise the MSE matrix.
S.Painit = zeros(nb);
if iscell(Opt.initcond) && ~isempty(Opt.initcond{2})
    % User-supplied initial condition.
    % Convert MSED[Xb] to MSE[Alpha].
    S.Painit = Opt.initcond{2}(:,:,1,min(end,ILoop));
    S.Painit = S.U \ S.Painit;
    S.Painit = S.Painit / S.U.';
elseif nb > nUnit ...
        && any(strcmpi(Opt.initcond,'stochastic'))
    % R matrix with rows corresponding to stable Alpha and columns
    % corresponding to transition shocks.
    RR = S.Ra(:,1:ne);
    RR = RR(ixStable,S.tshocks);
    % Reduced form covariance corresponding to stable alpha. Use the structural
    % shock covariance sub-matrix corresponding to transition shocks only in
    % the pre-sample period.
    Sa = RR*S.Omg(S.tshocks,S.tshocks,1)*RR.';
    % Compute asymptotic initial condition.
    if sum(ixStable) == 1
        Pa0stable = Sa / (1 - S.Ta(ixStable,ixStable).^2);
    else
        Pa0stable = ...
            covfun.lyapunov(S.Ta(ixStable,ixStable),Sa);
        Pa0stable = (Pa0stable + Pa0stable.')/2;
    end
    S.Painit(ixStable,ixStable) = Pa0stable;
end

end
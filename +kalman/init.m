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
a0 = zeros(nb,1);
if iscell(Opt.initcond)
    % User-supplied initial condition.
    % Convert Mean[Xb] to Mean[Alpha].
    a0 = Opt.initcond{1}(:,1,min(end,ILoop));
    toZero = isnan(a0) & ~S.ixRequired(:);
    a0(toZero) = 0;
    a0 = S.U \ a0;
elseif ~isempty(S.ka)
    % Asymptotic initial condition for the stable part of Alpha;
    % the unstable part is kept at zero initially.
    I = eye(nb - nUnit);
    a1 = zeros(nUnit,1);
    a2 = (I - S.Ta(ixStable,ixStable)) \ S.ka(ixStable,1);
    a0 = [a1;a2];
end

if nUnit > 0 && isnumeric(Opt.initmeanunit)
    % User supplied data to initialise mean for unit root processes.
    % Convert Xb to Alpha.
    xb0 = Opt.initmeanunit(:,1,min(end,ILoop));
    toZero = isnan(xb0) & ~S.ixRequired(:);
    xb0(toZero) = 0;
    a0(1:nUnit) = S.U(:,1:nUnit) \ xb0; 
end

% Initialise the MSE matrix.
Pa0 = zeros(nb);
if iscell(Opt.initcond) && ~isempty(Opt.initcond{2})
    % User-supplied initial condition.
    % Convert MSE[Xb] to MSE[Alpha].
    Pa0 = Opt.initcond{2}(:,:,1,min(end,ILoop));
    Pa0 = S.U \ Pa0;
    Pa0 = Pa0 / S.U.';
elseif nb > nUnit && any(strcmpi(Opt.initcond,'stochastic'))
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
    Pa0(ixStable,ixStable) = Pa0stable;
end

S.ainit = a0;
S.Painit = Pa0;

end
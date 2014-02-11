function [T,R,K,Z,H,D,U,Omg,list] = sspace(m,varargin)
% sspace  State-space matrices describing the model solution.
%
% Syntax
% =======
%
%     [T,R,K,Z,H,D,U,Omg] = sspace(m,...)
%
% Input arguments
% ================
%
% * `m` [ model ] - Solved model object.
%
% Output arguments
% =================
%
% * `T` [ numeric ] - Transition matrix.
%
% * `R` [ numeric ] - Matrix at the shock vector in transition equations.
%
% * `K` [ numeric ] - Constant vector in transition equations.
%
% * `Z` [ numeric ] - Matrix mapping transition variables to measurement
% variables.
%
% * `H` [ numeric ] - Matrix at the shock vector in measurement
% equations.
%
% * `D` [ numeric ] - Constant vector in measurement equations.
%
% * `U` [ numeric ] - Transformation matrix for predetermined variables.
%
% * `Omg` [ numeric ] - Covariance matrix of shocks.
%
% Options
% ========
%
% * `'triangular='` [ *`true`* | `false` ] - If true, the state-space form
% returned has the transition matrix `T` quasi triangular and the vector of
% predetermined variables transformed accordingly; this is the form used
% in IRIS calculations. If false, the state-space system refers to the
% original vector of transition variables.
%
% Description
% ============
%
% The state-space representation has the following form:
%
%     [xf;alpha] = T*alpha(-1) + K + R*e
%
%     y = Z*alpha + D + H*e
%
%     xb = U*alpha
%
%     Cov[e] = Omg
%
% where `xb` is an nb-by-1 vector of predetermined (backward-looking)
% transition variables and their auxiliary lags, `xf` is an nf-by-1 vector
% of non-predetermined (forward-looking) variables and their auxiliary
% leads, `alpha` is a transformation of `xb`, `e` is an ne-by-1 vector of
% shocks, and `y` is an ny-by-1 vector of measurement variables.
% Furthermore, we denote the total number of transition variables,
% and their auxiliary lags and leads, nx = nb + nf.
%
% The transition matrix, `T`, is, in general, rectangular nx-by-nb.
% Furthremore, the transformed state vector alpha is chosen so that the
% lower nb-by-nb part of `T` is quasi upper triangular.
%
% You can use the `get(m,'xVector')` function to learn about the order of
% appearance of transition variables and their auxiliary lags and leads in
% the vectors `xb` and `xf`. The first nf names are the vector `xf`, the
% remaining nb names are the vector `xb`.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

opt = passvalopt('model.sspace',varargin{:});

%--------------------------------------------------------------------------

[T,R,K,Z,H,D,U,Omg] = mysspace(m,':',true);
nx = size(T,1);
nb = size(T,2);
nf = nx - nb;
ne = sum(m.nametype == 3);
nAlt = size(m.Assign,3);

if ~opt.triangular
    % T <- U*T/U;
    % R <- U*R;
    % K <- U*K;
    % Z <- Z/U;
    % U <- eye
    for iAlt = 1 : nAlt
        T(:,:,iAlt) = T(:,:,iAlt) / U(:,:,iAlt);
        T(nf+1:end,:,iAlt) = U(:,:,iAlt)*T(nf+1:end,:,iAlt);
        R(nf+1:end,:,iAlt) = U(:,:,iAlt)*R(nf+1:end,:,iAlt);
        K(nf+1:end,:,iAlt) = U(:,:,iAlt)*K(nf+1:end,:,iAlt);
        Z(:,:,iAlt) = Z(:,:,iAlt) / U(:,:,iAlt);
        U(:,:,iAlt) = eye(size(U));
    end
end

list = m.solutionvector;

if opt.removeinactive
    active = ~diag(all(Omg == 0,3));
    R = reshape(R,[nx,ne,size(R,2)/ne]);
    R = R(:,active,:);
    R = R(:,:);
    H = H(:,active);
    Omg = Omg(active,active);
    if nargout > 8
        list{3} = list{3}(active);
    end
end

end
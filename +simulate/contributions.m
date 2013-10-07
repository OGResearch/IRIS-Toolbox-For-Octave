function S = contributions(S,NPer,Opt)
% contributions  Compute contributions of shocks and init.cond.+constant.
%
% Backed IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

ny = size(S.Z,1);
nx = size(S.T,1);
nb = size(S.T,2);
ne = size(S.e,1);
if isequal(NPer,Inf)
    NPer = size(S.e,2);
end

S.y = nan(ny,NPer,ne+1);
S.w = nan(nx,NPer,ne+1); % := [xf;a]

% Store input shocks.
e0 = S.e;

% Pre-allocate space for output contributions.
S.e = zeros(size(e0,1),size(e0,2),ne+1);

% Contributions of individual shocks.
for ii = 1 : ne
    S.e(ii,:,ii) = e0(ii,:);
    [S.y(:,:,ii),S.w(:,:,ii)] = simulate.plainlinear( ...
        S,zeros(nb,1),S.e(:,:,ii),NPer,true);
end

% Contribution of initial condition and constant.
[S.y(:,:,ne+1),S.w(:,:,ne+1)] = simulate.plainlinear( ...
    S,S.a0,S.e(:,:,ne+1),NPer,Opt.deviation);

end
function S = exogenise(S)
% exogenise  [Not a public function] Compute add-factors to endogenised
% shocks.
%
% Backed IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

nx = size(S.T,1);
nb = size(S.T,2);
nf = nx - nb;
ne = size(S.e,1);

% Convert w := [xf;a] vector to x := [xf;xb] vector.
x = S.w;
x(nf+1:end,:) = S.U*x(nf+1:end,:);

% Compute prediction errors.
% pe : = [ype(1);xpe(1);ype(2);xpe(2);...].
pe = [];
for t = 1 : S.lastexog
    pe = [pe; ...
        S.ytune(S.yAnchors(:,t),t)-S.y(S.yAnchors(:,t),t); ...
        S.xtune(S.xAnchors(:,t),t)-x(S.xAnchors(:,t),t); ...
        ]; %#ok<AGROW>
end

% Compute add-factors that need to be added to the current shocks.
if size(S.M,1) == size(S.M,2)
    
    % Exactly determined system
    %---------------------------
    upd = S.M \ pe;

else
    
    % Underdetermined system (larger number of shocks)
    %--------------------------------------------------
    d = [ ...
        S.weightsA(S.eaanchors); ...
        S.weightsU(S.euanchors) ...
        ].^2;
    nd = length(d);
    P = spdiags(d,0,nd,nd);
    %{
    PMt = P * S.M.';
    F = S.M * PMt;
    K = PMt / F;
    adde = K * pe;
    %}
    upd = simulate.update(S.M,P,pe);
    
end

nnzea = nnz(S.eaanchors(:,1:S.lastendoga));
eInxA = S.eaanchors(:,1:S.lastendoga);
eInxA = eInxA(:);
eInxU = S.euanchors(:,1:S.lastendogu);
eInxU = eInxU(:);
S.addea = zeros(ne,S.lastendoga);
S.addeu = zeros(ne,S.lastendogu);
S.addea(eInxA) = upd(1:nnzea);
S.addeu(eInxU) = upd(nnzea+1:end);

end
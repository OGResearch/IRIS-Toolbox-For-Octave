function M = multipliers(S,Ant)
% multipliers  [Not a public function] Compute anticipated or unanticipated multipliers.
%
% Backed IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

nx = size(S.T,1);
nb = size(S.T,2);
nf = nx - nb;
ne = size(S.e,1);

if Ant
    lastEndog = S.lastendoga;
else
    lastEndog = S.lastendogu;
end

% M := [My(1);Mx(1);My(1);Mx(1);...];
nnzy = nnz(S.yAnchors(:,1:S.lastexog));
nnzx = nnz(S.xAnchors(:,1:S.lastexog));
if Ant
    nnze = nnz(S.eaanchors);
else
    nnze = nnz(S.euanchors);
end
if S.lastexog == 0 || lastEndog == 0
    M = zeros(nnzy+nnzx,nnze);
    return
end
ma = zeros(nb,ne*lastEndog);
Tf = S.T(1:nf,:);
Ta = S.T(nf+1:end,:);
M = zeros(0,nnze);
if Ant
    eAnchors = S.eaanchors(:,1:lastEndog);
    eAnchors = eAnchors(:).';
    r = S.R(:,1:ne*lastEndog);
else
    eAnchors = S.euanchors(:,1:lastEndog);
    eAnchors = eAnchors(:).';
    r = S.R(:,1:ne);
end
for t = 1 : S.lastexog
    mf = Tf*ma;
    ma = Ta*ma;
    if Ant
        mf(:,(t-1)*ne+1:end) = mf(:,(t-1)*ne+1:end) + r(1:nf,:);
        ma(:,(t-1)*ne+1:end) = ...
            ma(:,(t-1)*ne+1:end) + r(nf+1:end,:);
        r = r(:,1:end-ne);
    elseif t <= lastEndog
        mf(:,(t-1)*ne+(1:ne)) = mf(:,(t-1)*ne+(1:ne)) + r(1:nf,:);
        ma(:,(t-1)*ne+(1:ne)) = ...
            ma(:,(t-1)*ne+(1:ne)) + r(nf+1:end,:);
    end
    my = S.Z*ma;
    if t <= lastEndog
        my(:,(t-1)*ne+(1:ne)) = my(:,(t-1)*ne+(1:ne)) + S.H;
    end
    yAnchors = S.yAnchors(:,t);
    xfAnchors = S.xAnchors(1:nf,t);
    xbAnchors = S.xAnchors(nf+1:end,t);
    M = [ ...
        M; ...
        my(yAnchors,eAnchors); ...
        mf(xfAnchors,eAnchors); ...
        S.U(xbAnchors,:)*ma(:,eAnchors); ...
        ]; %#ok<AGROW>
end

end
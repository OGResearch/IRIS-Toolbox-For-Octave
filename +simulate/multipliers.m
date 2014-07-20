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
    lastEndg = S.LastEndgA;
else
    lastEndg = S.LastEndgU;
end

% M := [My(1);Mx(1);My(2);Mx(2);...];
nnzy = nnz(S.YAnch(:,1:S.LastExg));
nnzx = nnz(S.XAnch(:,1:S.LastExg));
if Ant
    nnze = nnz(S.EaAnch);
else
    nnze = nnz(S.EuAnch);
end
if S.LastExg == 0 || lastEndg == 0
    M = zeros(nnzy+nnzx,nnze);
    return
end
ma = zeros(nb,ne*lastEndg);
Tf = S.T(1:nf,:);
Ta = S.T(nf+1:end,:);
M = zeros(0,nnze);
if Ant
    eAnch = S.EaAnch(:,1:lastEndg);
    eAnch = eAnch(:).';
    r = S.R(:,1:ne*lastEndg);
else
    eAnch = S.EuAnch(:,1:lastEndg);
    eAnch = eAnch(:).';
    r = S.R(:,1:ne);
end

for t = 1 : S.LastExg
    mf = Tf*ma;
    ma = Ta*ma;
    if Ant
        mf(:,(t-1)*ne+1:end) = mf(:,(t-1)*ne+1:end) + r(1:nf,:);
        ma(:,(t-1)*ne+1:end) = ...
            ma(:,(t-1)*ne+1:end) + r(nf+1:end,:);
        r = r(:,1:end-ne);
    elseif t <= lastEndg
        mf(:,(t-1)*ne+(1:ne)) = mf(:,(t-1)*ne+(1:ne)) + r(1:nf,:);
        ma(:,(t-1)*ne+(1:ne)) = ...
            ma(:,(t-1)*ne+(1:ne)) + r(nf+1:end,:);
    end
    my = S.Z*ma;
    if t <= lastEndg
        my(:,(t-1)*ne+(1:ne)) = my(:,(t-1)*ne+(1:ne)) + S.H;
    end
    yAnch = S.YAnch(:,t);
    xfAnch = S.XAnch(1:nf,t);
    xbAnch = S.XAnch(nf+1:end,t);
    M = [ ...
        M; ...
        my(yAnch,eAnch); ... Y
        mf(xfAnch,eAnch); ... Xf
        S.U(xbAnch,:)*ma(:,eAnch); ... Xb := U*Alp
        ]; %#ok<AGROW>
end

end
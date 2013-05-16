function [Y2,F2,B2,E2,r] = onestepbackmean(S,Time,Pe,A0,F0,YDelta,D,r)
% onestepbackmse  [Not a public function] One-step backward smoothing for point estimates.
%
% Backed IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

ny = size(S.Z,1);
nf = size(S.Tf,1);
ne = size(S.Ra,2);
nPOut = S.npout;
tShocks = S.tshocks;
mShocks = S.mshocks;
Ra = S.Ra(:,1:ne);
Omg = S.Omg(:,:,min(Time,end));

jy = S.yindex(:,Time);
Fipe = S.F(jy,jy,Time) \ Pe(jy,:);

nCol = size(Pe,2);
Y2 = nan(ny,nCol);
E2 = zeros(ne,nCol);
F2 = zeros(nf,nCol);

isRZero = all(r(:) == 0);

% Measurement shocks.
if any(jy)
    K0 = S.Ta*S.K1(:,jy,Time);
    HOmg = S.H(jy,mShocks)*Omg(mShocks,:);
    if isRZero
        E2 = E2 + HOmg.'*Fipe;
    else
        E2 = E2 + HOmg.'*(Fipe - K0.'*r);
    end
end

% Update `r`.
if isRZero
    r = S.Zt(:,jy)*Fipe;
else
    r = S.Zt(:,jy)*Fipe + S.L(:,:,Time).'*r;
end

% Transition variables.
A2 = A0 + S.Pa0(:,:,Time)*r;
if nf > 0
    F2 = F0 + S.Pfa0(:,:,Time)*r;
end
B2 = S.U*A2;

% Transition shocks.
RaOmg = Ra(:,tShocks)*Omg(tShocks,:);
E2 = E2 + RaOmg.'*r;

% Back out NaN measurement variables.
if any(~jy)
    Y2(~jy,:) = S.Z(~jy,:)*A2 + S.H(~jy,:)*E2;
    if nPOut > 0
        % Correct the estimates of NaN observations for the effect of estimated
        % out-of-lik parameters.
        Y2(~jy,:) = Y2(~jy,:) + YDelta(~jy,:);
    end
    if ~isempty(D)
        % Correct the estimates of NaN observations for deterministic trends.
        Y2(~jy,1) = Y2(~jy,1) + D(~jy,:);
    end
end
    
end
function [AddEa,AddEu] = exogenise(S)
% exogenise  [Not a public function] Compute add-factors to endogenised shocks.
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

% Convert w := [xf;a] vector to x := [xf;xb] vector.
x = S.w;
x(nf+1:end,:) = S.U*x(nf+1:end,:);

% Compute prediction errors.
% pe : = [ype(1);xpe(1);ype(2);xpe(2);...].
pe = [];
for t = 1 : S.LastExg
    pe = [pe; ...
        S.YTune(S.YAnch(:,t),t)-S.y(S.YAnch(:,t),t); ...
        S.XTune(S.XAnch(:,t),t)-x(S.XAnch(:,t),t); ...
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
        S.WghtA(S.EaAnch); ...
        S.WghtU(S.EuAnch) ...
        ].^2;
    nd = length(d);
    P = spdiags(d,0,nd,nd);
    upd = simulate.updatemean(S.M,P,pe);
    
end

nnzea = nnz(S.EaAnch(:,1:S.LastEndgA));
eInxA = S.EaAnch(:,1:S.LastEndgA);
eInxA = eInxA(:);
eInxU = S.EuAnch(:,1:S.LastEndgU);
eInxU = eInxU(:);

AddEa = zeros(ne,S.LastEndgA);
AddEu = zeros(ne,S.LastEndgU);
AddEa(eInxA) = upd(1:nnzea);
AddEu(eInxU) = upd(nnzea+1:end);

end
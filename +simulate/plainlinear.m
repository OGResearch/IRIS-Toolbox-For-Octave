function [Y,W,E] = plainlinear(S,A0,E,Nper,Dev,Q,q)
% plainlinear  [Not a public function] Plain linear simulation.
%
% Backed IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

% TODO: Simplify treatment of ea and eu.

%#ok<*VUNUS>
%#ok<*CTCH>

% The input struct S must at least include
%
% * The system matrices `.T`, `.R`, `.K`, `.Z`, `.H`, `.D`;
%
% * The anticipation functions `.antFunc` and `.unantFunc`.
%

try
    Q;
catch
    Q = [];
end

try
    q;
catch
    q = [];
end

%--------------------------------------------------------------------------

ny = size(S.Z,1);
nx = size(S.T,1);
nb = size(S.T,2);
nf = nx - nb;
try
    ne = size(S.e,1);
catch
    ne = size(E,1);
end

T = S.T;
R = S.R;
K = S.K;
Z = S.Z;
H = S.H;
D = S.D;

Y = nan(ny,Nper);
W = nan(nx,Nper); % W := [xf;a].

ea = S.antFunc(E);
eu = S.unantFunc(E);

lastA = utils.findlast(ea);
lastU = utils.findlast(eu);
ia = any(abs(R(:,1:ne*lastA)) > 0,1);
iu = any(abs(R(:,1:ne)) > 0,1);

% Non-linear add-factors.
isNonlin = ~isempty(Q) && ~isempty(q);
if isNonlin
    nn = size(q,1);
    lastN = utils.findlast(q);
    in = any(abs(Q(:,1:nn*lastN)) > 0,1);
end

% Transition variables
%----------------------
for t = 1 : Nper
    if t == 1
        W(:,t) = T*A0;
    else
        W(:,t) = T*W(nf+1:end,t-1);
    end
    if ~Dev
        W(:,t) = W(:,t) + K;
    end
    if lastA > 0 && any(ia)
        eat = ea(:,t:t+lastA-1);
        eat = eat(:);
        W(:,t) = W(:,t) + R(:,ia)*eat(ia);
        lastA = lastA - 1;
        ia = ia(1,1:end-ne);
    end
    if lastU > 0 && any(iu)
        W(:,t) = W(:,t) + R(:,iu)*eu(iu,t);
        lastU = lastU - 1;
    end
    if isNonlin && lastN > 0 && any(in)
        qt = q(:,t:t+lastN-1);
        qt = qt(:);
        W(:,t) = W(:,t) + Q(:,in)*qt(in);
        lastN = lastN - 1;
        in = in(1,1:end-nn);
    end
end

% Mesurement variables
%----------------------
if ny > 0
    Y = Z*W(nf+1:end,1:Nper) +...
        H*(eu(:,1:Nper) + ea(:,1:Nper));
    if ~Dev
        Y = Y + D(:,ones(1,Nper));
    end
end

end

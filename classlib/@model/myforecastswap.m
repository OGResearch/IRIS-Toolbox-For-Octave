function [M,Ma,N,Na] = myforecastswap(This,IAlt,Exi,Endi,Last)
% myforecastswap  [Not a public function] Model solution matrices with some of the variables exogenised and shocks endogenised.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

ny = sum(This.nametype == 1);
nx = size(This.solution{1},1);
nb = size(This.solution{1},2);
nf = nx - nb;
ne = sum(This.nametype == 3);

% Current-dated variables in the original state vector.
xCurri = imag(This.solutionid{2}) == 0;
nXCurr = sum(xCurri);
fCurri = xCurri(1:nf);
bCurri = xCurri(nf+1:end);

% Constant.
Mxc = zeros(nXCurr*Last,1);
Myc = zeros(ny*Last,1);
mac = zeros(nb,1);
% Multipliers on initial condition.
Mx0 = zeros(nXCurr*Last,nb);
My0 = zeros(ny*Last,nb);
ma0 = eye(nb);
% Multipliers on unexpected shocks.
Mxu = zeros(nXCurr*Last,ne*Last);
Myu = zeros(ny*Last,ne*Last);
mau = zeros(nb,ne*Last);
% Multipliers on expected shocks.
Mxe = zeros(nXCurr*Last,ne*Last);
Mye = zeros(ny*Last,ne*Last);
mae = zeros(nb,ne*Last);

% System matrices.
Tf = This.solution{1}(1:nf,:,IAlt);
Ta = This.solution{1}(nf+1:end,:,IAlt);
Ru = This.solution{2}(:,1:ne,IAlt);
Re = This.solution{2}(:,1:ne*Last,IAlt);
Kf = This.solution{3}(1:nf,IAlt);
Ka = This.solution{3}(nf+1:end,IAlt);
Z = This.solution{4}(:,:,IAlt);
H = This.solution{5}(:,:,IAlt);
D = This.solution{6}(:,IAlt);
U = This.solution{7}(:,:,IAlt);
Ucurr = U(bCurri,:);

for t = 1 : Last
    % Constant.
    mfc = Tf*mac + Kf;
    mac = Ta*mac + Ka;
    Mxc((t-1)*nXCurr+(1:nXCurr),1) = [mfc(fCurri,:);Ucurr*mac];
    Myc((t-1)*ny+(1:ny),1) = Z*mac + D;
    % Initial condition.
    mf0 = Tf*ma0;
    ma0 = Ta*ma0;
    Mx0((t-1)*nXCurr+(1:nXCurr),:) = [mf0(fCurri,:);Ucurr*ma0];
    My0((t-1)*ny+(1:ny),:) = Z*ma0;
    % Unexpected.
    mfu = Tf*mau;
    mau = Ta*mau;
    mfu(:,(t-1)*ne+(1:ne)) = mfu(:,(t-1)*ne+(1:ne)) + Ru(1:nf,:);
    mau(:,(t-1)*ne+(1:ne)) = mau(:,(t-1)*ne+(1:ne)) + Ru(nf+1:end,:);
    myu = Z*mau;
    myu(:,(t-1)*ne+(1:ne)) = myu(:,(t-1)*ne+(1:ne)) + H;
    Mxu((t-1)*nXCurr+(1:nXCurr),:) = [mfu(fCurri,:);Ucurr*mau];
    Myu((t-1)*ny+(1:ny),:) = myu;
    % Expected.
    mfe = Tf*mae;
    mae = Ta*mae;
    mfe(:,(t-1)*ne+1:end) = mfe(:,(t-1)*ne+1:end) + Re(1:nf,:);
    mae(:,(t-1)*ne+1:end) = mae(:,(t-1)*ne+1:end) + Re(nf+1:end,:);
    Re(:,end-ne+1:end) = [];
    mye = Z*mae;
    mye(:,(t-1)*ne+(1:ne)) = mye(:,(t-1)*ne+(1:ne)) + H;
    Mxe((t-1)*nXCurr+(1:nXCurr),:) = [mfe(fCurri,:);Ucurr*mae];
    Mye((t-1)*ny+(1:ny),:) = mye;
end

% Original system I*[Y;X] = M1*[U;E].
M = [Myc,My0,Myu,Mye;Mxc,Mx0,Mxu,Mxe];
Ma = [mac,ma0,mau,mae];

% When computing MSE matrices, we treat expected shocks as unexpected.
if nargout > 2
    N = [Myc,My0,Myu,Myu;Mxc,Mx0,Mxu,Mxu];
    Na = [mac,ma0,mau,mau];
end

if any(Exi) || any(Endi)
    % Add the alpha vector at t=last so that it is easy to retrieve the
    % initial condition for simulating the model after t=last.
    M = [Ma;M];
    Exi = [false(1,nb),Exi];
    % Swap the endogenised and exogenised columns in I and A matrices.
    I = eye(size(M,1));
    I1 = I(:,~Exi);
    I2 = I(:,Exi);
    M1 = M(:,~Endi);
    M2 = M(:,Endi);
    M = [I1,-M2]\[M1,-I2];
    Ma = M(1:nb,:);
    M = M(nb+1:end,:);
    if nargout > 2
        N = [Na;N];
        N1 = N(:,~Endi);
        N2 = N(:,Endi);
        N = [I1,-N2]\[N1,-I2];
        Na = N(1:nb,:);
        N = N(nb+1:end,:);
    end
end

end
function dev = chksolution(m,ialt)

dev = [];

select = false;
linear = m.linear;
eqselect = myaffectedeqtn(m,ialt,select,linear);
eqselect(m.eqtntype == 3) = false;
[m,deriv] = myderiv(m,eqselect,ialt,true,m.linear);
[m,system] = mysystem(m,deriv,eqselect,ialt);

ny = length(m.solutionid{1});
nx = length(m.solutionid{2});
ne = length(m.solutionid{3});
nb = size(m.solution{1},2);
nf = nx - nb;

T = m.solution{1}(:,:,ialt);
R = m.solution{2}(:,:,ialt);
Kf = m.solution{3}(1:nf,:,ialt);
Ka = m.solution{3}(nf+1:end,:,ialt);
Z = m.solution{4}(:,:,ialt);
H = m.solution{5}(:,:,ialt);
D = m.solution{6}(:,:,ialt);
Za = m.solution{7}(:,:,ialt);
k0 = size(R,2)/ne - 1;

R = reshape(R,nx,ne,k0+1);

Tf = T(1:nf,:,ialt);
Ta = T(nf+1:end,:);
Rf = R(1:nf,:);
Ra = R(nf+1:end,:);

k = size(Ra,2)/ne;
Rf = reshape(Rf,nf,ne,k);
Ra = reshape(Ra,nb,ne,k);

% Measurement equations.
if ny > 0
    A = system.A{1};
    B = system.B{1};
    E = system.E{1};
    K = system.K{1};
    dev(end+1) = maxabs(A*Z + B*Za);
    dev(end+1) = maxabs(A*H + E);
    if m.linear
        dev(end+1) = maxabs(A*D + K);
    end
end

% Transition equations.
A = system.A{2};
B = system.B{2};
A1 = A(:,1:nf);
A2 = A(:,nf+1:end);
B1 = B(:,1:nf);
B2 = B(:,nf+1:end);
E = system.E{2};
E = [E;zeros([size(A,1)-size(E,1),size(E,2)])];
K = system.K{2};

dev(end+1) = maxabs(A1*Tf*Ta + A2*Za*Ta + B1*Tf + B2*Za);
dev(end+1) = maxabs(A1*Tf*Ra(:,:,1) + A2*Za*Ra(:,:,1) + B1*Rf(:,:,1) + E);
if m.linear
    dev(end+1) = maxabs(A1*(Tf*Ka+Kf) + A2*Za*Ka + B1*Kf + K);
end

for i = 2 : size(Ra,3)
    dev(end+1) = maxabs(A1*(Tf*Ra(:,:,i) + Rf(:,:,i-1)) ...
        + A2*Za*Ra(:,:,i) + B1*Rf(:,:,i)); %#ok<AGROW>
end

end
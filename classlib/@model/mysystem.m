function [This,System] = mysystem(This,Deriv,EqSelect,IAlt)
% mysystem  [Not a public function] Unsolved system matrices.
%
% Backed IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

nm = sum(This.eqtntype == 1);
nt = sum(This.eqtntype == 2);
mInx = find(EqSelect(1:nm));
tInx = find(EqSelect(nm+1:end));

ny = length(This.systemid{1});
nx = length(This.systemid{2});
ne = length(This.systemid{3});
nf = sum(double(imag(This.systemid{2}) >= 0));
nb = nx - nf;

System = This.system0;

% A1 y + B1 xb+ + E1 e + K1 = 0

System.K{1}(mInx) = Deriv.c(mInx);
System.K{2}(tInx) = Deriv.c(nm+tInx);

System.A{1}(mInx,This.metasystem.y) = ...
    Deriv.f(mInx,This.metaderiv.y);
System.B{1}(mInx,This.metasystem.pplus) = ...
    Deriv.f(mInx,This.metaderiv.pplus);
System.E{1}(mInx,This.metasystem.e) = ....
    Deriv.f(mInx,This.metaderiv.e);
System.N{1} = [];

% A2 [xf+;xb+] + B2 [xf;xb] + E2 e + K2 = 0

System.A{2}(tInx,This.metasystem.uplus) = ...
    Deriv.f(nm+tInx,This.metaderiv.uplus);
System.A{2}(tInx,nf+This.metasystem.pplus) = ...
    Deriv.f(nm+tInx,This.metaderiv.pplus);
System.B{2}(tInx,This.metasystem.u) = ...
    Deriv.f(nm+tInx,This.metaderiv.u);
System.B{2}(tInx,nf+This.metasystem.p) = ...
    Deriv.f(nm+tInx,This.metaderiv.p);
System.E{2}(tInx,This.metasystem.e) = ...
    Deriv.f(nm+tInx,This.metaderiv.e);

System.A{2}(nt+1:nx,:) = This.systemident.xplus;
System.B{2}(nt+1:nx,:) = This.systemident.x;

System.N{2}(tInx,:) = Deriv.n(nm+tInx,:);

if IAlt == 1
    for i = 1 : 2
        This.system0.A{i}(:) = System.A{i}(:);
        This.system0.B{i}(:) = System.B{i}(:);
        This.system0.E{i}(:) = System.E{i}(:);
        This.system0.K{i}(:) = System.K{i}(:);
        This.system0.N{i}(:) = System.N{i}(:);
    end
end

end

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

System = This.system0;

% Measurement equations
%------------------------
% A1 y + B1 xb+ + E1 e + K1 = 0
System.K{1}(mInx) = Deriv.c(mInx);
System.A{1}(mInx,This.d2s.y) = Deriv.f(mInx,This.d2s.y_);
System.B{1}(mInx,This.d2s.xp1) = Deriv.f(mInx,This.d2s.xp1_);
System.E{1}(mInx,This.d2s.e) = Deriv.f(mInx,This.d2s.e_);

% Transition equations
%----------------------
% A2 [xf+;xb+] + B2 [xf;xb] + E2 e + K2 = 0
System.K{2}(tInx) = Deriv.c(nm+tInx);
System.A{2}(tInx,This.d2s.xu1) = Deriv.f(nm+tInx,This.d2s.xu1_);
System.A{2}(tInx,This.d2s.xp1) = Deriv.f(nm+tInx,This.d2s.xp1_);
System.B{2}(tInx,This.d2s.xu) = Deriv.f(nm+tInx,This.d2s.xu_);
System.B{2}(tInx,This.d2s.xp) = Deriv.f(nm+tInx,This.d2s.xp_);
System.E{2}(tInx,This.d2s.e) = Deriv.f(nm+tInx,This.d2s.e_);

% Add dynamic identity matrices
%-------------------------------
System.A{2}(nt+1:end,:) = This.d2s.ident1;
System.B{2}(nt+1:end,:) = This.d2s.ident;

% Effect of non-linear equations
%--------------------------------
System.N{1} = [];
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
function This = myresetlastsyst(This)
% myresetlastsyst  [Not a public function] Reset handle to last system.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

% Parameters and steady states
%------------------------------
asgn = nan(1,size(This.name,2));

% Derivatives
%-------------
if issparse(This.occur)
    nt = size(This.occur,2)/length(This.name);
else
    nt = size(This.occur,3);
end
nDerv = nt*sum(This.nametype <= 3);
nEqtn12 = sum(This.eqtntype <= 2);
derv = struct();
derv.c = zeros(nEqtn12,1);
derv.f = sparse(zeros(nEqtn12,nDerv));
tempEye = -eye(nEqtn12);
derv.n = tempEye(:,This.nonlin);

% System matrices
%-----------------
% Sizes of system matrices (different from solution matrices).
ny = sum(This.nametype == 1);
nx = length(This.systemid{2});
nf = sum(imag(This.systemid{2}) >= 0);
nb = nx - nf;
ne = sum(This.nametype == 3);

syst = struct();
syst.K{1} = zeros(ny,1);
syst.K{2} = zeros(nx,1);
syst.A{1} = sparse(zeros(ny,ny));
syst.B{1} = sparse(zeros(ny,nb));
syst.E{1} = sparse(zeros(ny,ne));
syst.N{1} = [];
syst.A{2} = sparse(zeros(nx,nx));
syst.B{2} = sparse(zeros(nx,nx));
syst.E{2} = sparse(zeros(nx,ne));
syst.N{2} = zeros(nx,sum(This.nonlin));

This.lastSyst.asgn = asgn;
This.lastSyst.derv = derv;
This.lastSyst.syst = syst;

end
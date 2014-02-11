function This = myprealloc(This,Ny,P,NXPer,NAlt,NGrp)
% myprealloc  [Not a public function] Pre-allocate VAR matrices before estimation.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

This.A = nan(Ny,Ny*P,NAlt);
This.Omega = nan(Ny,Ny,NAlt);
This.eigval = nan(1,Ny*P,NAlt);
This.fitted = false(NGrp,NXPer,NAlt);

end
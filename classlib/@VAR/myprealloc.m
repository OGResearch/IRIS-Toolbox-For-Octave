function This = myprealloc(This,Ny,P,Ng,NXPer,NLoop)
% myprealloc  [Not a public function] Pre-allocate VAR matrices before estimation.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

if ispanel(This)
    nGrp = length(This.GroupNames);
else
    nGrp = 1;
end

This.K = nan(Ny,nGrp,NLoop);
This.A = nan(Ny,Ny*P,NLoop);
This.G = nan(Ny,Ng,NLoop);
This.Omega = nan(Ny,Ny,NLoop);
This.T = nan(Ny*P,Ny*P,NLoop);
This.U = nan(Ny*P,Ny*P,NLoop);
This.eigval = nan(1,Ny*P,NLoop);
This.Sigma = [];
This.aic = nan(1,NLoop);
This.sbc = nan(1,NLoop);

This.fitted = false(nGrp,NXPer,NLoop);

end
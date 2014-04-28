function This = myprealloc(This,Ny,P,NXPer,NAlt,NGrp,Ng)
% myprealloc  [Not a public function] Pre-allocate VAR matrices before estimation.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

This = myprealloc@varobj(This,Ny,P,NXPer,NAlt,NGrp);

This.K = nan(Ny,NGrp,NAlt);
This.G = nan(Ny,Ng,NAlt);
This.T = nan(Ny*P,Ny*P,NAlt);
This.U = nan(Ny*P,Ny*P,NAlt);
This.Sigma = [];
This.aic = nan(1,NAlt);
This.sbc = nan(1,NAlt);
This.Zi = zeros(0,Ny*P+1);

end
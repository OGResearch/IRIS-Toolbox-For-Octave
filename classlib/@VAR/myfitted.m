function [This,Fitted,DatFitted] = myfitted(This,Resid)
% myfitted  [Not a public function] Fitted periods in PVAR esimation.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

ny = size(This.A,1);
p = size(This.A,2) / max(ny,1);

if ispanel(This)
    nGrp = length(This.GroupNames);
else
    nGrp = 1;
end

Fitted = all(~isnan(Resid),1);
Fitted = reshape(Fitted,length(Fitted)/nGrp,nGrp).';
Fitted(:,end-p+1:end,:) = [];

DatFitted = cell(nGrp,1);
for iGrp = 1 : nGrp
    iFitted = Fitted(iGrp,:);
    DatFitted{iGrp} = This.range(iFitted);
end

end
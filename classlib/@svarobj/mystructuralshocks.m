function Outp = mystructuralshocks(This,Inp,Opt)
% mystructuralshocks  [Not a public function] Convert reduced-form VAR
% residuals to structural VAR shocks.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

% Panel SVARs.
if ispanel(This)
    Outp = mygroupmethod(@mystructuralshocks,This,Inp,Opt);
    return
end

%--------------------------------------------------------------------------

ny = size(This.A,1);
nAlt = size(This.A,3);

% Input data.
[outpFmt,range,~,e] = mydatarequest(This,Inp,Inf,Opt);

if size(e,3) == 1 && nAlt > 1
    e = e(:,:,ones(1,nAlt));
end

for iAlt = 1 : nAlt
    if This.rank < ny
        e(:,:,iAlt) = pinv(This.B(:,:,iAlt)) * e(:,:,iAlt);
    else
        e(:,:,iAlt) = This.B(:,:,iAlt) \ e(:,:,iAlt);
    end
end

% Output data.
eNames = get(This,'eNames');
Outp = myoutpdata(This,outpFmt,range,e,[],eNames,Inp);

end
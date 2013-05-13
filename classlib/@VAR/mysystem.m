function [A,B,K,Omg,iAlt] = mysystem(This,iAlt)
% mysystem  [Not a public function] VAR system matrices.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

try
    nAlt = size(This.A,3);
    iAlt = min(iAlt,nAlt);
catch %#ok<CTCH>
    iAlt = ':';
end

%--------------------------------------------------------------------------

A = This.A(:,:,iAlt);
K = This.K(:,:,iAlt);
Omg = This.Omega(:,:,iAlt);
B = [];

end
function hdatainit(This,H)
% hdatainit  [Not a public function] Initialise hdataobj for VAR.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

ny = size(This.A,1);
nx = length(This.XNames);
ne = ny;
ni = length(This.INames);

H.Id = { 1:ny, ny+(1:nx), ny+nx+(1:ne), ny+nx+ne+(1:ni) };
H.Name = [ This.YNames, This.XNames, This.ENames, This.INames ];
H.Log = false(size(H.Name));
H.Label = [ This.YNames, This.XNames, This.ENames, This.INames ];

if isequal(H.Contrib,'E')
    H.Contrib = [ This.ENames, {'Init+Const'} ];
elseif isequal(H.Contrib,'Y')
    H.Contrib = This.YNames;
end

end
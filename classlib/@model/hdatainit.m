function hdatainit(This,H)
% hdatainit  [Not a public function] Initialize hdataobj for model.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

H.Id = This.solutionid;
H.Name = This.name;
H.LogSign = This.LogSign;

label = This.namelabel;
ixEmpty = cellfun(@isempty,label);
label(ixEmpty) = This.name(ixEmpty);
H.Label = label;

if isequal(H.Contributions,@E)
    H.Contributions = [ This.name(This.nametype == 3), ...
        {'Init+Const+DTrends'}, {'Nonlinear'} ];
elseif isequal(H.Contributions,@Y)
    H.Contributions = This.name(This.nametype == 1);
end

end
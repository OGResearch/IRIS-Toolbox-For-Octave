function This = mystruct2obj(This,S)
% mystruct2obj  [Not a public function] Copy structure fields to object properties.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

propList = xxPropList(This);
structList = xxPropList(S);

for i = 1 : length(propList)
    inx = strcmpi(structList,propList{i});
    if ~any(inx)
        continue
    end
    for pos = find(inx(:).')
        This.(propList{i}) = S.(structList{pos});
    end
end

end


% Subfunctions...


%**************************************************************************


function List = xxPropList(This)

if isstruct(This)
    List = fieldnames(This);
    return
end

% List of non-dependent object properties.
if ischar(This)
    mc = meta.class.fromName(This);
else
    mc = metaclass(This);
end
try
    inx = ~[mc.PropertyList.Dependent];
    List = {mc.PropertyList(inx).Name};
catch %#ok<CTCH>
    % Compatibility with R2010b.
    p = [mc.Properties{:}];
    inx = ~[p.Dependent];
    List = {p.Name};
    List = List(inx);
end

end % xxPropList()
function This = mystruct2obj(This,S)
% mystruct2obj  [Not a public function] Copy structure fields to object properties.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

propList = getsetobj.proplist(This);
structList = getsetobj.proplist(S);

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
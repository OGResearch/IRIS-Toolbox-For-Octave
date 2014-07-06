function [List,IxRemove,IxMultiple] = unique(List)
% unique  [Not a public function] Return unique cellstr and index of items to remove from original list.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

List = List(:).';
nList = length(List);
IxRemove = false(1,nList);
IxMultiple = false(1,nList);
ixProcessed = false(1,nList);
for i = 1 : nList
    if ixProcessed(i)
        continue
    end
    ix = strcmp(List{i},List);
    ixProcessed(ix) = true;
    fix = find(ix);
    if length(fix) > 1
        IxRemove = IxRemove | ix;
        IxRemove(fix(end)) = false;
        IxMultiple(fix(end)) = true;
    end
end

List(IxRemove) = [];

end
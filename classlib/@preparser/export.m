function export(This,C)
% export  Export carry-around files.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isempty(C) || ~isstruct(C)
    return
end

n = length(C);
thisDir = cd();
deleted = false(1,n);
file = cell(1,n);
fileName = get(This,'filename');
br = sprintf('\n');
stamp = [ ...
    '% Carry-around file exported from ',fileName,'.',br, ...
    '% Saved on ',datestr(now()),'.'];
for i = 1 : n
    name = C(i).filename;
    body = C(i).content;
    file{i} = fullfile(thisDir,name);
    if exist(file{i},'file')
        deleted(i) = true;
    end
    body = [stamp,br,body]; %#ok<AGROW>
    char2file(body,file{i});
end

if any(deleted)
    if ~ischar(This)
        objclass = class(This);
    end
    utils.warning(objclass, ...
        ['This file has been deleted when creating a carry-around file ', ...
        'with the same name: ''%s''.'], ...
        file{deleted});
end
rehash();

end
function export(OBJ,C)
% export  Export carry-around files.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isempty(C) || ~isstruct(C)
    return
end

n = length(C);
thisdir = cd();
deleted = false(1,n);
file = cell(1,n);
fname = get(OBJ,'filename');
br = sprintf('\n');
stamp = [ ...
    '% Carry-around file exported from ',fname,'.',br, ...
    '% Saved on ',datestr(now()),'.'];
for i = 1 : n
    name = C(i).filename;
    body = C(i).content;
    file{i} = fullfile(thisdir,name);
    if exist(file{i},'file')
        deleted(i) = true;
    end
    body = [stamp,br,body]; %#ok<AGROW>
    char2file(body,file{i});
end

if any(deleted)
    if ~ischar(OBJ)
        objclass = class(OBJ);
    end
    utils.warning(objclass, ...
        ['This file has been deleted when creating a carry-around file ', ...
        'with the same name: ''%s''.'], ...
        file{deleted});
end
rehash();

end
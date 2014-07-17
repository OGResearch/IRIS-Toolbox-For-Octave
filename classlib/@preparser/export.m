function export(This,E)
% export  Export carry-around files.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isempty(E) || ~isstruct(E)
    return
end

n = length(E);
thisDir = pwd();
deleted = false(1,n);
file = cell(1,n);
fileName = get(This,'filename');
br = sprintf('\n');
stamp = [ ...
    '% Carry-around file exported from ',fileName,'.',br, ...
    '% Saved on ',datestr(now()),'.'];
for i = 1 : n
    c = E(i).Content;
    file{i} = fullfile(thisDir,E(i).FName);
    if exist(file{i},'file')
        deleted(i) = true;
    end
    c = [stamp,br,c]; %#ok<AGROW>
    char2file(c,file{i});
end

if any(deleted)
    utils.warning('preparser:export', ...
        ['This file has been deleted when creating a carry-around file ', ...
        'with the same name: ''%s''.'], ...
        file{deleted});
end
rehash();

end

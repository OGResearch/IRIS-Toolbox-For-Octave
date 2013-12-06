function [Path,Folder] = findtexmf(File)
% findtexmf  Try to locate TeX executables.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

Path = '';
Folder = '';

% Try FINDTEXMF only on non-Unix platforms.
if ~isunix()
    [flag,outp] = system(['findtexmf --file-type=exe ',File]);
else
    % Try /usr/texbin first.
    list = dir(fullfile('/usr/texbin',File));
    if length(list) == 1
        Folder = '/usr/texbin';
        Path = fullfile(Folder,File);
    end
    % Try WHICH next.
    [flag,outp] = system(['which ',File]);
end

if flag == 0
    % Use the correctly spelled path and the right file separators.
    [Folder,fname,fext] = fileparts(strtrim(outp));
    Path = fullfile(Folder,[fname,fext]);
end

end
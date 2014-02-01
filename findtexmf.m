function [Path,Folder] = findtexmf(File)
% findtexmf  Try to locate TeX executables.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

Path = '';
Folder = '';

% Try FINDTEXMF first.
[flag,outp] = system(['findtexmf --file-type=exe ',File]);

% If FINDTEXMF fails, try to run WHICH on Unix platforms.
if flag ~= 0 && isunix()
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
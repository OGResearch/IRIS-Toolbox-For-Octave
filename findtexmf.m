function [path,folder] = findtexmf(file)
% findtexmf  Run KPSEWHICH to locate TeX executables.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%**************************************************************************
    
    path = '';
    folder = '';
    
    % Try FINDTEXMF first.
    [flag,output] = system(['findtexmf --file-type=exe ',file]);
    
    % If FINDTEXMF fails, try to run WHICH on Unix platforms.
    if flag ~= 0 && isunix()
        [flag,output] = system(['which ',file]);
    end
    
    if flag == 0
        % Use the correctly spelled path and the right file separators.
        [folder,fname,fext] = fileparts(strtrim(output));
        path = fullfile(folder,[fname,fext]);
    end
    
end
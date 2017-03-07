function C = grabcommentblk(Trace)
% grabcommentblk  [Not a public function] Grab first curly comment block placed after the calling function.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

C = '';

% Read the file into a cellstr with EOLs removed.
file = file2char(Trace.file,'cellstr');

% Find the first opening %{ and the matching closing %}.
open = NaN;
close = NaN;
level = 0;
for i = Trace.line+1 : length(file)
    line = strtrim(file{i});
    if strcmp(line,'%{')
        level = level + 1;
        if level == 1
            open = i;
        end
    end
    if strcmp(line,'%}')
        if level == 1
            close = i;
        end
        level = level - 1;
    end
    if ~isnan(open) && ~isnan(close)
        C = sprintf('%s\n',file{open+1:close-1});
        break
    end
end

end

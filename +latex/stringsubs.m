function C = stringsubs(C)
% stringsubs  [Not a public function] Treat LaTeX special characters in a
% string.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

if iscellstr(C)
    for i = 1 : numel(C)
        C{i} = latex.stringsubs(C{i});
    end
    return
end

%--------------------------------------------------------------------------

if isempty(C)
    return
end

offset = irisget('highcharcode');
store = {};
open = find(C == '{',1,'first');
count = 0;
while ~isempty(open)
    close = open-1 + strfun.matchbrk(C(open:end));
    if isempty(close)
        open = [];
    else
        count = count + 1;
        store{end+1} = C(open+1:close-1); %#ok<AGROW>
        C = [C(1:open-1),char(offset+count),C(close+1:end)];
        open = find(C == '{',1,'first');
    end
end

C = strrep(C,'\','\textbackslash ');
C = strrep(C,'_','\_');
C = strrep(C,'%','\%');
C = strrep(C,'$','\$');
C = strrep(C,'#','\#');
C = strrep(C,'&','\&');
C = strrep(C,'<','\ensuremath{<}');
C = strrep(C,'>','\ensuremath{>}');
C = strrep(C,'~','\ensuremath{\sim}');
C = regexprep(C,'(?<!\.)\.\.\.(?!\.)','\\ldots{}');

for i = 1 : numel(store)
    C = strrep(C,char(offset+i),store{i});
end

end

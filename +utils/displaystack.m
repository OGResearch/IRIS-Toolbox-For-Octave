function C = displaystack(Stack)
% displaystack  [Not a public function] Display warning-style stack of callers.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

C = '';

for i = 1 : length(Stack)
    if i == 1
        C = [C,sprintf('\n> ')]; %#ok<AGROW>
    else
        C = [C,sprintf('\n  ')]; %#ok<AGROW>
    end
    if ismatlab
        http = sprintf( ...
            'matlab: matlab.desktop.editor.openAndGoToLine(''%s'',%g);', ...
            Stack(i).file,Stack(i).line);
        C = [C,sprintf('In <a href="%s">%s at %g</a>', ...
            http,Stack(i).name,Stack(i).line)]; %#ok<AGROW>
    else
        C = [C,sprintf('In %s at %g',Stack(i).name, ...
            Stack(i).line)]; %#ok<AGROW>
    end
end

end
function C = interpret(This,C)
% interpret  [Not a public function] Intepret user input text.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

switch This.options.inputformat
    case 'plain'
        C = latex.stringsubs(C);
    case 'latex'
        % Do nothing.
end

end
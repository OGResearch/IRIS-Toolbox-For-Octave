function [This,NewPos,NewChar] = copytoend(This,Pos)
% copytoend  [Not a public function] Copy given entry to end of storage.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

This.Storage{end+1} = This.Storage{Pos};
This.Open{end+1} = This.Open{Pos};
This.Close{end+1} = This.Close{Pos};

NewPos = length(This.Storage);
NewChar = charcode(This);

end
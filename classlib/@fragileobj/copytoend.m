function [This,NewPos,K] = copytoend(This,Pos)
% copytoend  [Not a public function] Copy the entry at a given position at the end.
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

K = round(This.Offset + NewPos);
K = char(K);

end
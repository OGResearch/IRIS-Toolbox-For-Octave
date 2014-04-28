function [This,NewPos,K] = copytoend(This,Pos)
% copytoend  [Not a public function] Copy the entry at a given position at the end.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

This.storage{end+1} = This.storage{Pos};
This.open{end+1} = This.open{Pos};
This.close{end+1} = This.close{Pos};

NewPos = length(This.storage);

K = round(This.offset + NewPos);
K = char(K);

end
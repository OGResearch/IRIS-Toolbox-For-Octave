function C = charcode(This)
% charcode  [Not a public function] Get the current replacement code.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

C = [char(2),dec2char(This,length(This)),char(3)];

end
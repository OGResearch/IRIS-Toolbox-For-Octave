function Flag = isequal(This,That)
% isequal  [Not a public function] Compare userdataobj objects.
%
% Backed IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

Flag = isequal(This.Comment,That.Comment) ...
    && isequal(This.UserData,That.UserData) ...
    && isequal(This.Caption,That.Caption);

end
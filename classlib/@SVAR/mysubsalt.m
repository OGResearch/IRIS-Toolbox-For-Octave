function This = mysubsalt(This,Lhs,Obj,Rhs)
% mysubsalt  [Not a public function] Implement SUBSREF and SUBSASGN for SVAR objects with multiple params.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

if nargin == 2
    
    % Subscripted reference This(Lhs).
    This = mysubsalt@VAR(This,Lhs);
    This.B = This.B(:,:,Lhs);
    This.std = This.std(:,Lhs);

elseif nargin == 3 && isempty(Obj)

    % Empty subscripted assignment This(Lhs) = empty.
    This = mysubsalt@VAR(This,Lhs,[]);
    This.B(:,:,Lhs) = [];
    This.std(:,Lhs) = [];

elseif nargin == 4 && strcmp(class(This),class(Obj))

    % Proper subscripted assignment This(Lhs) = Obj(Rhs).
    This = mysubsalt@VAR(This,Lhs,Obj,Rhs);
    This.B(:,:,Lhs) = Obj.B(:,:,Rhs);
    This.std(:,Lhs) = Obj.std(:,Rhs);

else
    utils.error('SVAR','Invalid assignment to a SVAR object.');
end

end
function This = mysubsalt(This,Lhs,Obj,Rhs)
% mysubsalt  [Not a public function] Implement subsref and subsasgn for SVAR objects with multiple params.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

if nargin == 2
    % Subscripted reference This(Lhs).
    This = mysubsalt@VAR(This,Lhs);
    This = mysubsalt@svarobj(This,Lhs);
elseif nargin == 3 && isempty(Obj)
    % Empty subscripted assignment This(Lhs) = empty.
    This = mysubsalt@VAR(This,Lhs,[]);
    This = mysubsalt@svarobj(This,Lhs,[]);
elseif nargin == 4 && mycompatible(This,Obj)
    % Proper subscripted assignment This(Lhs) = Obj(Rhs).
    This = mysubsalt@VAR(This,Lhs,Obj,Rhs);
    This = mysubsalt@svarobj(This,Lhs,Obj,Rhs);
else
    utils.error('SVAR:mysubsalt', ...
        'Invalid assignment to a %s object.', ...
        class(This));
end

end
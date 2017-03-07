function This = mysubsalt(This,Lhs,Obj,Rhs)
% mysubsalt  [Not a public function] Implement subsref and subsasgn for svarobj class.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

if nargin == 2
    % Subscripted reference This(Lhs).
    This.B = This.B(:,:,Lhs);
    This.Std = This.Std(:,Lhs);
    This.Method = This.Method(1,Lhs);
elseif nargin == 3 && isempty(Obj)
    % Empty subscripted assignment This(Lhs) = empty.
    This.B(:,:,Lhs) = [];
    This.Std(:,Lhs) = [];
    This.Method(1,Lhs) = [];
elseif nargin == 4 && mycompatible(This,Obj)
    % Proper subscripted assignment This(Lhs) = Obj(Rhs).
    try
        This.B(:,:,Lhs) = Obj.B(:,:,Rhs);
        This.Std(:,Lhs) = Obj.Std(:,Rhs);
        This.Method(1,Lhs) = Obj.Method(1,Rhs);
    catch %#ok<CTCH>
        utils.error('svarobj:mysubsalt', ...
            ['Subscripted assignment failed, ', ...
            'LHS and RHS objects are incompatible.']);
    end
else
    utils.error('svarobj:mysubsalt', ...
        'Invalid assignment to a %s object.', ...
        class(This));
end

end
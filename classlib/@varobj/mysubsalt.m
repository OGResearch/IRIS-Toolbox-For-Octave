function This = mysubsalt(This,Lhs,Obj,Rhs)
% mysubs [Not a public function] Implement SUBSREF and SUBSASGN for varobj objects with multiple parameterisations.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

if nargin == 2
    % Subscripted reference This(Lhs).
    This.A = This.A(:,:,Lhs);
    This.Omega = This.Omega(:,:,Lhs);
    This.EigVal = This.EigVal(1,:,Lhs);
    This.Fitted = This.Fitted(1,:,Lhs);
elseif nargin == 3 && isempty(Obj)
    % Empty subscripted assignment This(Lhs) = empty.
    This.A(:,:,Lhs) = [];
    This.Omega(:,:,Lhs) = [];
    This.EigVal(:,:,Lhs) = [];
    This.Fitted(:,:,Lhs) = [];
elseif nargin == 4 && mycompatible(This,Obj)
    try
        This.A(:,:,Lhs) = Obj.A(:,:,Rhs);
        This.Omega(:,:,Lhs) = Obj.Omega(:,:,Rhs);
        This.EigVal(:,:,Lhs) = Obj.EigVal(:,:,Rhs);
        This.Fitted(:,:,Lhs) = Obj.Fitted(:,:,Rhs);
    catch %#ok<CTCH>
        utils.error('varobj:mysubsalt', ...
            ['Subscripted assignment failed, ', ...
            'LHS and RHS objects are incompatible.']);
    end
else
    utils.error('varobj:mysubsalt', ...
        'Invalid assignment to a %s object.', ...
        class(This));
end

end
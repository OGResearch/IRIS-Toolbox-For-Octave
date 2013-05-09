function This = mysubsalt(This,Lhs,Obj,Rhs)
% mysubs [Not a public function] Implement SUBSREF and SUBSASGN for varobj objects with multiple parameterisations.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

if nargin == 2
    
    % Subscripted reference This(Lhs).
    This.A = This.A(:,:,Lhs);
    This.Omega = This.Omega(:,:,Lhs);
    This.eigval = This.eigval(1,:,Lhs);
    This.fitted = This.fitted(1,:,Lhs);
    
elseif nargin == 3 && isempty(Obj)
    
    % Empty subscripted assignment This(Lhs) = empty.
    This.A(:,:,Lhs) = [];
    This.Omega(:,:,Lhs) = [];
    This.eigval(:,:,Lhs) = [];
    This.fitted(:,:,Lhs) = [];
    
elseif nargin == 4 && isa(This,'varobj') && isa(Obj,'varobj')
    
    % Proper subscripted assignment This(Lhs) = Obj(Rhs).
    
    if ~iscompatible(This,Obj)
        doIncompatible();
    end
    
    try
        This.A(:,:,Lhs) = Obj.A(:,:,Rhs);
        This.Omega(:,:,Lhs) = Obj.Omega(:,:,Rhs);
        This.eigval(:,:,Lhs) = Obj.eigval(:,:,Rhs);
        This.fitted(:,:,Lhs) = Obj.fitted(:,:,Rhs);
    catch %#ok<CTCH>
        utils.error('varobj', ...
            'Cannot concatenate incompatible %s objects.', ...
            class(This));
    end
    
else
    utils.error('varobj', ...
        'Invalid assignment to a %s object.', ...
        class(This));
end

end
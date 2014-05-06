function This = mysubsalt(This,Lhs,Obj,Rhs)
% mysubsalt [Not a public function] Implement SUBSREF and SUBSASGN for VAR objects with multiple parameterisations.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

if nargin == 2
    % Subscripted reference This(Lhs).
    This = mysubsalt@varobj(This,Lhs);
    This.K = This.K(:,:,Lhs);
    This.G = This.G(:,:,Lhs);
    This.Aic = This.Aic(1,Lhs);
    This.Sbc = This.Sbc(1,Lhs);
    This.T = This.T(:,:,Lhs);
    This.U = This.U(:,:,Lhs);
    if ~isempty(This.Sigma)
        This.Sigma = This.Sigma(:,:,Lhs);
    end
elseif nargin == 3 && isempty(Obj)
    % Empty subscripted assignment This(Lhs) = empty.
    This = mysubsalt@varobj(This,Lhs,Obj);
    This.K(:,:,Lhs) = [];
    This.G(:,:,Lhs) = [];
    This.Aic(:,Lhs) = [];
    This.Sbc(:,Lhs) = [];
    This.T(:,:,Lhs) = [];
    This.U(:,:,Lhs) = [];
    if ~isempty(This.Sigma) && ~isempty(x.Sigma)
        This.Sigma(:,:,Lhs) = [];
    end
elseif nargin == 4 && mycompatible(This,Obj)
    % Proper subscripted assignment This(Lhs) = Obj(Rhs).
    This = mysubsalt@varobj(This,Lhs,Obj,Rhs);
    try
        This.K(:,:,Lhs) = Obj.K(:,:,Rhs);
        This.G(:,:,Lhs) = Obj.G(:,:,Rhs);
        This.Aic(:,Lhs) = Obj.Aic(:,Rhs);
        This.Sbc(:,Lhs) = Obj.Sbc(:,Rhs);
        This.T(:,:,Lhs) = Obj.T(:,:,Rhs);
        This.U(:,:,Lhs) = Obj.U(:,:,Rhs);
        if ~isempty(This.Sigma) && ~isempty(Obj.Sigma)
            This.Sigma(:,:,Lhs) = Obj.Sigma(:,:,Rhs);
        end
    catch %#ok<CTCH>
        utils.error('VAR:mysubsalt', ...
            ['Subscripted assignment failed, ', ...
            'LHS and RHS objects are incompatible.']);
    end
else
    utils.error('VAR:mysubsalt', ...
        'Invalid assignment to a %s object.', ...
        class(This));
end

end
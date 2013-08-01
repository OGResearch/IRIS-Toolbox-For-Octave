function This = mysubsalt(This,LhsInx,Obj,RhsInx)
% mysubsalt  [Not a public function] Implement SUBSREF and SUBSASGN for
% model objects with multiple parameterisations.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

if nargin == 2
    
    % Subscripted reference `This(LhsInx)`.
    This = mysubsalt@modelobj(This,LhsInx);
    
    % Model class specific properties.
    This.eigval = This.eigval(1,:,LhsInx);
    This.icondix = This.icondix(1,:,LhsInx);
    for i = 1 : length(This.solution)
        This.solution{i} = This.solution{i}(:,:,LhsInx);
    end
    for i = 1 : length(This.Expand)
        This.Expand{i} = This.Expand{i}(:,:,LhsInx);
    end
    
elseif nargin == 3 && isempty(Obj)
    
    % Empty subscripted assignment `This(LhsInx) = []`.
    This = mysubsalt@modelobj(This,LhsInx,Obj);
    
    % Model class specific properties.
    This.eigval(:,:,LhsInx) = [];
    This.icondix(:,:,LhsInx) = [];
    for i = 1 : length(This.solution)
        This.solution{i}(:,:,LhsInx) = [];
    end
    for i = 1 : length(This.Expand)
        This.Expand{i}(:,:,LhsInx) = [];
    end
    
elseif nargin == 4 && strcmp(class(This),class(Obj))
    
    % Proper subscripted assignment `This(LhsInx) = Obj(RhsInx)`.
    This = mysubsalt@modelobj(This,LhsInx,Obj,RhsInx);
    
    % Model class specific properties.
    This.eigval(1,:,LhsInx) = Obj.eigval(1,:,RhsInx);
    This.icondix(1,:,LhsInx) = Obj.icondix(1,:,RhsInx);
    for i = 1 : length(This.solution)
        This.solution{i}(:,:,LhsInx) = Obj.solution{i}(:,:,RhsInx);
    end
    for i = 1 : length(This.Expand)
        This.Expand{i}(:,:,LhsInx) = Obj.Expand{i}(:,:,RhsInx);
    end
    
end

end
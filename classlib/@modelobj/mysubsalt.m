function This = mysubsalt(This,LhsInx,Obj,RhsInx)
% mysubsalt  [Not a public function] Implement SUBSREF and SUBSASGN for
% modelobj with multiple parameterisations.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

if nargin == 2
    
    % Subscripted reference `This(Lhs)`.
    This.Assign = This.Assign(1,:,LhsInx);
    This.stdcorr = This.stdcorr(1,:,LhsInx);
    
elseif nargin == 3 && isempty(Obj)
    
    % Empty subscripted assignment `This(Lhs) = []`.
    This.Assign(:,:,LhsInx) = [];
    This.stdcorr(:,:,LhsInx) = [];
    
elseif nargin == 4 && strcmp(class(This),class(Obj))
    
    % Proper subscripted assignment `This(LhsInx) = Obj(RhsInx)`.
    This.Assign(1,:,LhsInx) = Obj.Assign(1,:,RhsInx);
    This.stdcorr(1,:,LhsInx) = Obj.stdcorr(1,:,RhsInx);
    
end

end
function Flag = mycompatible(V1,V2)
% mycompatible  [Not a public function] True if two svarobj objects can occur together on the LHS and RHS in an assignment.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

try
    Flag = issvarobj(V1) && issvarobj(V2);   
catch %#ok<CTCH>
    Flag = false;
end

end
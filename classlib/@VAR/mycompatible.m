function Flag = mycompatible(V1,V2)
% mycompatible  [Not a public function] True if two VAR objects can occur together on the LHS and RHS in an assignment.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

try
    Flag = mycompatible@varobj(V1,V2) ...
        && isa(V1,'VAR') && isa(V2,'VAR') ...
        && V1.nhyper == V2.nhyper ...
        && isequal(V1.inames,V2.inames) ...
        && isequal(V1.Zi,V2.Zi);
catch %#ok<CTCH>
    Flag = false;
end

end
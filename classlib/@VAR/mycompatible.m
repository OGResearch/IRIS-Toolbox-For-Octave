function Flag = mycompatible(V1,V2)
% mycompatible  [Not a public function] True if two VAR objects can occur together on the LHS and RHS in an assignment.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

try
    Flag = mycompatible@varobj(V1,V2) ...
        && isa(V1,'VAR') && isa(V2,'VAR') ...
        && V1.NHyper == V2.NHyper ...
        && isequal(V1.INames,V2.INames) ...
        && isequal(V1.Zi,V2.Zi);
catch %#ok<CTCH>
    Flag = false;
end

end
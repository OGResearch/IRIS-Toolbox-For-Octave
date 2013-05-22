function Flag = iscompatible(M1,M2)
% iscompatible  [Not a public function] True if two modelobj objects can occur together on the LHS and RHS in an assignment.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

try
    Flag = isa(M1,'modelobj') && isa(M2,'modelobj') ...
        && length(M1.name) == length(M2.name) ...
        && all(strcmp(M1.name,M2.name)) ...
        && all(M1.nametype == M2.nametype);
catch %#ok<CTCH>
    Flag = false;
end

end
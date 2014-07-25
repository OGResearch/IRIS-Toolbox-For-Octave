function Flag = iscompatible(M1,M2)
% iscompatible  [Not a public function] True if two modelobj objects can occur together on the LHS and RHS in an assignment.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

if true % ##### MOSW
    className = 'modelobj';
else
    className = 'model'; %#ok<UNRCH>
end

try
    Flag = isa(M1,className) && isa(M2,className) ...
        && length(M1.name) == length(M2.name) ...
        && all(strcmp(M1.name,M2.name)) ...
        && all(M1.nametype == M2.nametype);
catch %#ok<CTCH>
    Flag = false;
end

end

function Flag = iscompatible(M1,M2)
% iscompatible  True if two models can occur together on the LHS and RHS in an assignment.
%
% Syntax
% =======
%
%     Flag = iscompatible(M1,M2)
%
% Input arguments
% ================
%
% * `M1`, `M2` [ model ] - Two model objects that will be tested for
% compatibility.
%
% Output arguments
% =================
%
% * `Flag` [ `true` | `false` ] - True if `M1` and `M1` can occur in an
% assignment, `M1(...) = M2(...)` or horziontal concatenation, `[M1,M2]`.
%
% Description
% ============
%
% The function compares the names of all variables, shocks, and parameters,
% and the composition of the state-space vectors.
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

try
    Flag = iscompatible@modelobj(M1,M2) ...
        && isa(M1,'model') && isa(M2,'model') ...
        && all(M1.solutionid{2} == M2.solutionid{2});
catch %#ok<CTCH>
    Flag = false;
end

end
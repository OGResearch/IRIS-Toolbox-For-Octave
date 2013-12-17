function [This,Invalid,NonUnique] = myautoexogenise(This,Lhs,Rhs)
% myautoexogenise  [Not a public function] Define variable/shock pairs for
% autoexogenise.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

This.Autoexogenise = nan(size(This.name));

% Total number of definitions.
n = length(Lhs);
Invalid = false(1,n);

NonUnique = strfun.nonunique(Rhs);
if ~isempty(NonUnique)
    return
end

% Permissible names on the LHS (measurement or transition variables).
lhsName = This.name;
lhsName(This.nametype > 2) = {''};

% Permissible names on the RHS (shocks).
rhsName = This.name;
rhsName(This.nametype ~= 3) = {''};
for i = 1 : n
    lhs = Lhs{i};
    rhs = Rhs{i};
    if isempty(lhs) || ~ischar(lhs) ...
            || isempty(rhs) || ~ischar(rhs)
        Invalid(i) = true;
        continue
    end
    lhsInx = strcmp(lhsName,lhs);
    rhsInx = strcmp(rhsName,rhs);
    if ~any(lhsInx)
        Invalid(i) = true;
        continue
    end
    if ~any(rhsInx)
        Invalid(i) = true;
        continue
    end
    This.Autoexogenise(lhsInx) = find(rhsInx);
end

end
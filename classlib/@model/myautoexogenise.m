function [This,IxValid,Multiple] = myautoexogenise(This,Lhs,Rhs)
% myautoexogenise  [Not a public function] Define variable/shock pairs for
% autoexogenise.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

flNameType = floor(This.nametype);
This.Autoexogenise = nan(size(This.name));

% Total number of definitions.
n = length(Lhs);
IxValid = true(1,n);

Multiple = strfun.nonunique(Rhs);

% Permissible names on the LHS (measurement or transition variables).
lhsName = This.name;
lhsName(flNameType > 2) = {''};

% Permissible names on the RHS (shocks).
rhsName = This.name;
rhsName(flNameType ~= 3) = {''};
for i = 1 : n
    lhs = Lhs{i};
    rhs = Rhs{i};
    if isempty(lhs) || ~ischar(lhs) ...
            || isempty(rhs) || ~ischar(rhs)
        IxValid(i) = false;
        continue
    end
    lhsInx = strcmp(lhsName,lhs);
    rhsInx = strcmp(rhsName,rhs);
    if ~any(lhsInx)
        IxValid(i) = false;
        continue
    end
    if ~any(rhsInx)
        IxValid(i) = false;
        continue
    end
    This.Autoexogenise(lhsInx) = find(rhsInx);
end

end
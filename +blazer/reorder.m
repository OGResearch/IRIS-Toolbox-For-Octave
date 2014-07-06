function [OrdName,OrdEqtn,Occ] = reorder(Occ)
% reorder  [Not a public function] Block-recursive reordering.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isempty(Occ)
    OrdName = zeros(1,0);
    OrdEqtn = zeros(1,0);
    return
end

c1 = colamd(Occ);
Occ = Occ(:,c1);
r1 = colamd(Occ.');
Occ = Occ(r1,:);
[r2,c2] = dmperm(Occ);
Occ = Occ(r2,c2);

OrdName = 1 : size(Occ,2);
OrdEqtn = 1 : size(Occ,1);

OrdName = OrdName(c1);
OrdName = OrdName(c2);
OrdEqtn = OrdEqtn(r1);
OrdEqtn = OrdEqtn(r2);

end
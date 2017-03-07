function [FName,FEqtn,LName,LEqtn,Occ,OName,OEqtn] = firstlast(Occ,OccName)
% firstlast  [Not a public function] Deal with leading and trailing 1-by-1 blocks of equations.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

% `FName`, `FEqtn` ... names and equations ordered first.
% `LName`, `LEqtn` ... names and equations ordered last.
% `OName`, `OEqtn` ... other names and equations.

% Equations with only one variable. These can be computed first.
%----------------------------------------------------------------

n = size(Occ,1);
% Number of variables in each equation.
nOccur = sum(Occ,2);
% Find equations with only one variables; these will be ordered first.
FEqtn = find(nOccur == 1).';
% Set up a vector of variable occuring in first equations.
FName = [];
for i = FEqtn
    FName(end+1) = find(Occ(i,:)); %#ok<AGROW>
end

% First names must be unique.
xxChkUnique(OccName,FName);

% Remove first equations from array.
Occ(FEqtn,:) = [];
% Remove first names from array.
Occ(:,FName) = [];
OccName(:,FName) = [];
% Set up a vector of remaining equations.
oEqtn1 = 1 : n;
oEqtn1(FEqtn) = [];
% Set up a vector of remaining names.
oName1 = 1 : n;
oName1(FName) = [];

% Variables that only occur in one equation. These can be computed last.
%-----------------------------------------------------------------------

n = size(Occ,1);
nOccur = sum(Occ,1);
LName = find(nOccur == 1);
% Last names must be unique.
xxChkUnique(OccName,LName);
LEqtn = [];
for i = LName
    LEqtn(end+1) = find(Occ(:,i)); %#ok<AGROW>
end
Occ(LEqtn,:) = [];
Occ(:,LName) = [];
OccName(:,LName) = [];
otherName2 = 1 : n;
otherName2(LName) = [];
otherEqtn2 = 1 : n;
otherEqtn2(LEqtn) = [];

OName = oName1(otherName2);
OEqtn = oEqtn1(otherEqtn2);
LName = oName1(LName);
LEqtn = oEqtn1(LEqtn);

if (~isempty(FName) || ~isempty(LName)) ...
        && ~isempty(OName)
    
    [fName0,fEqtn0,lName0,lEqtn0,Occ,oName0,oEqtn0] ...
        = blazer.firstlast(Occ,OccName);
    
    FName = [FName,OName(fName0)];
    FEqtn = [FEqtn,OEqtn(fEqtn0)];
    LName = [OName(lName0),LName];
    LEqtn = [OEqtn(lEqtn0),LEqtn];
    OName = OName(oName0);
    OEqtn = OEqtn(oEqtn0);
end

end


% Subfunctions...


%**************************************************************************


function xxChkUnique(List,Pos)
[u,inx] = unique(Pos);
if length(u) ~= length(Pos)
    Pos(inx) = [];
    List = unique(List(Pos));
    utils.error('model:blazer', ...
        'Steady-state singularity in the following variable: ''%s''.', ...
        List{:});
end
end % xxChkUnique()

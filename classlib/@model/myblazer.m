function this = myblazer(this)
% myblazer  [Not a public function] Block-recursive analyzer of steady-state equations.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%**********************************************************************

this.nameblk = {};
this.eqtnblk = {};

if any(this.nametype == 1)
    type = [2,1];
else
    type = 2;
end

for i = type
    occur = this.occurS(this.eqtntype == i,this.nametype == i);
    occurname = this.name(this.nametype == i);
    
    % Find equations that only have one variable in them; these can
    % come first based on input parameters. Find names that occur only
    % in one equation; these can come last based on all other
    % variables.
    [firstName,firstEqtn,lastName,lastEqtn, ...
        otherOccur,otherName,otherEqtn] = xxone(occur,occurname);
    
    % Try to re-arrange the rest of equations and names in recursive
    % blocks.
    [nameOrd,eqtnOrd] = xxreorder(otherOccur);
    
    otherName = otherName(nameOrd);
    otherEqtn = otherEqtn(eqtnOrd);
    otherOccur = otherOccur(eqtnOrd,nameOrd);
    
    [nameblk,eqtnblk] = xxgetblks(otherOccur,otherName,otherEqtn);
    nameblkAdd = [num2cell(firstName),nameblk,num2cell(lastName)];
    eqtnblkAdd = [num2cell(firstEqtn),eqtnblk,num2cell(lastEqtn)];
    
    nameThisType = 1 : length(this.name);
    nameThisType = nameThisType(this.nametype == i);
    eqtnThisType = 1 : length(this.eqtn);
    eqtnThisType = eqtnThisType(this.eqtntype == i);
    
    for j = 1 : length(nameblkAdd)
        nameblkAdd{j} = nameThisType(nameblkAdd{j});
        eqtnblkAdd{j} = eqtnThisType(eqtnblkAdd{j});
    end
    
    this.nameblk = [this.nameblk,nameblkAdd];
    this.eqtnblk = [this.eqtnblk,eqtnblkAdd];
    
end

end

% Subfunctions.

%**************************************************************************
function [firstName,firstEqtn,lastName,lastEqtn, ...
    occur,otherName,otherEqtn] = xxone(occur,occurname)

% Equations with only one variable. These can be computed first.
%===============================================================

n = size(occur,1);
% Number of variables in each equation.
noccur = sum(occur,2);
% Find equations with only one variables; these will be ordered first.
firstEqtn = find(noccur == 1).';
% Set up a vector of variable occuring in first equations.
firstName = [];
for i = firstEqtn
    firstName(end+1) = find(occur(i,:)); %#ok<AGROW>
end
% First names must be unique.
xxchkunique(occurname,firstName);
% Remove first equations from array.
occur(firstEqtn,:) = [];
% Remove first names from array.
occur(:,firstName) = [];
occurname(:,firstName) = [];
% Set up a vector of remaining equations.
otherEqtn1 = 1 : n;
otherEqtn1(firstEqtn) = [];
% Set up a vector of remaining names.
otherName1 = 1 : n;
otherName1(firstName) = [];

% Variables that only occur in one equation. These can be computed last.
%=======================================================================

n = size(occur,1);
noccur = sum(occur,1);
lastName = find(noccur == 1);
% Last names must be unique.
xxchkunique(occurname,lastName);
lastEqtn = [];
for i = lastName
    lastEqtn(end+1) = find(occur(:,i)); %#ok<AGROW>
end
occur(lastEqtn,:) = [];
occur(:,lastName) = [];
occurname(:,lastName) = [];
otherName2 = 1 : n;
otherName2(lastName) = [];
otherEqtn2 = 1 : n;
otherEqtn2(lastEqtn) = [];

otherName = otherName1(otherName2);
otherEqtn = otherEqtn1(otherEqtn2);
lastName = otherName1(lastName);
lastEqtn = otherEqtn1(lastEqtn);

if (~isempty(firstName) || ~isempty(lastName)) ...
        && ~isempty(otherName)
    [firstName_,firstEqtn_,lastName_,lastEqtn_, ...
        occur,otherName_,otherEqtn_] = xxone(occur,occurname);
    firstName = [firstName,otherName(firstName_)];
    firstEqtn = [firstEqtn,otherEqtn(firstEqtn_)];
    lastName = [otherName(lastName_),lastName];
    lastEqtn = [otherEqtn(lastEqtn_),lastEqtn];
    otherName = otherName(otherName_);
    otherEqtn = otherEqtn(otherEqtn_);
end
end % xxone().

%**************************************************************************
function [reordName,reordEqtn] = xxreorder(occur)
if isempty(occur)
    reordName = [];
    reordEqtn = [];
    return
end
[nEqtn,nName] = size(occur);
[ans,reordEqtn] = sort(-sum(occur,2)); %#ok<NOANS,ASGLU>
reordEqtn = reordEqtn(:).';
[ans,reordName] = sort(sum(occur,1)); %#ok<NOANS,ASGLU>
reordName0 = zeros(size(reordName));
reordEqtn0 = zeros(size(reordEqtn));
count = 0;
while (any(reordName ~= reordName0) ...
        || any(reordEqtn ~= reordEqtn0)) ...
        && count < 500
    reordName0 = reordName;
    reordEqtn0 = reordEqtn;
    tmp = occur(reordEqtn,reordName);
    tmpReord = 1 : nName;
    for iEqtn = nEqtn : -1 : 1
        aux = find(tmp(iEqtn,:));
        tmp(:,aux) = true;
        aux = [find(~tmp(iEqtn,:)),aux]; %#ok<AGROW>
        tmpReord(:) = tmpReord(aux);
        tmp = tmp(:,aux);
    end
    reordName(:) = reordName(tmpReord);
    tmp = occur(reordEqtn,reordName);
    tmpReord = 1 : nEqtn;
    for iName = 1 : nName
        aux = transpose(find(tmp(:,iName)));
        tmp(aux,:) = true;
        aux = [aux,transpose(find(~tmp(:,iName)))]; %#ok<AGROW>
        tmpReord(:) = tmpReord(aux);
        tmp = tmp(aux,:);
    end
    reordEqtn(:) = reordEqtn(tmpReord);
    count = count + 1;
end
end % xxreorder().

%**************************************************************************
function [nameblk,eqtnblk] = xxgetblks(occur,nameOrd,eqtnOrd)
n = size(occur,1);
nameblk = {};
eqtnblk = {};
thisnameblk = [];
thiseqtnblk = [];
for i = n : -1 : 1
    thisnameblk(end+1) = nameOrd(i); %#ok<AGROW>
    thiseqtnblk(end+1) = eqtnOrd(i); %#ok<AGROW>
    if ~any(any(occur(i:end,1:i-1)))
        nameblk{end+1} = thisnameblk; %#ok<AGROW>
        eqtnblk{end+1} = thiseqtnblk; %#ok<AGROW>
        thisnameblk = [];
        thiseqtnblk = [];
    end
end
end % xxgetblks().

%**************************************************************************
function xxchkunique(list,pos)
[aux,index] = unique(pos);
if length(aux) ~= length(pos)
    pos(index) = [];
    list = unique(list(pos));
    utils.error('model', ...
        'Steady-state singularity in the following variable: ''%s''.', ...
        list{:});
end
end % xxchkunique().
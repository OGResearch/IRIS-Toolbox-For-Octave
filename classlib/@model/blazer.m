function [NameBlk,EqtnBlk] = blazer(This,varargin)
% blazer  Reorder steady-state equations into block-recursive structure.
%
% Syntax
% =======
%
%     [NameBlk,EqtnBlk] = blazer(M,...)
%
% Input arguments
% ================
%
% * `M` [ model ] - Model object.
%
% Output arguments
% =================
%
% * `M` [ model ] - Model object with variables and steady-state equations
% regrouped to create block-recursive structure.
%
% * `NameBlk` [ cell ] - Cell of cellstr with variable names in each block.
%
% * `EqtnBlk` [ cell ] - Cell of cellstr with equations in each blocks.
%
% Description
% ============
% 
% The reordering algorithm first identifies equations with a single
% variable in each, and variables occurring in a single equation each, and
% then uses a combination of column and row approximate minimum degree
% permutations (`colamd`) followed by a Dulmage-Mendelsohn permutation
% (`dmperm`).
%
% The output arguments `NameBlk` and `EqtnBlk` are 1-by-N cell arrays,
% where N is the number of blocks, and each cell is a 1-by-Kn cell array of
% strings, where Kn is the number of variables and equations in block N.
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

Human = isempty(varargin) || ~isequal(varargin{1},false);

%--------------------------------------------------------------------------

NameBlk = cell(1,0);
EqtnBlk = cell(1,0);

if This.linear
    return
end

if any(This.nametype == 1)
    type = [2,1];
else
    type = 2;
end

for i = type
    occ = This.occurS(This.eqtntype == i,This.nametype == i);
    occName = This.name(This.nametype == i);
    
    % Find equations that only have one variable in them; these can
    % come first based on input parameters. Find names that occur only
    % in one equation; these can come last based on all other
    % variables.
    [fName,fEqtn,lName,lEqtn,oOcc,oName,oEqtn] ...
        = blazer.firstlast(occ,occName);
    
    % Reorder the rest of equations and names into recursive blocks.
    [ordName,ordEqtn] = blazer.reorder(oOcc);
    
    oName = oName(ordName);
    oEqtn = oEqtn(ordEqtn);
    oOcc = oOcc(ordEqtn,ordName);
    
    [oName,oEqtn] = blazer.getblocks(oOcc,oName,oEqtn);
    nameBlkAdd = [num2cell(fName),oName,num2cell(lName)];
    eqtnBlkAdd = [num2cell(fEqtn),oEqtn,num2cell(lEqtn)];
    
    nameThisType = 1 : length(This.name);
    nameThisType = nameThisType(This.nametype == i);
    eqtnThisType = 1 : length(This.eqtn);
    eqtnThisType = eqtnThisType(This.eqtntype == i);
    
    for j = 1 : length(nameBlkAdd)
        nameBlkAdd{j} = nameThisType(nameBlkAdd{j});
        eqtnBlkAdd{j} = eqtnThisType(eqtnBlkAdd{j});
    end
    
    NameBlk = [NameBlk,nameBlkAdd]; %#ok<AGROW>
    EqtnBlk = [EqtnBlk,eqtnBlkAdd]; %#ok<AGROW>
end

if Human
    % Return human-readable variable names and equations.
    NameBlk = blazer.human(This.name,NameBlk);
    EqtnBlk = blazer.human(This.eqtn,EqtnBlk);
end

end

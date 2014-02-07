function [This,Pos] = select(This,RowSelect,ColSelect)
% select  Select submatrix by referring to row names and column names.
%
% Syntax
% =======
%
%     [X,Pos] = select(This,RowSelect,ColSelect)
%     [X,Pos] = select(X,Select)
%
% Input arguments
% ================
% 
% * `X` [ namedmat ] - Matrix or array with named rows and columns.
%
% * `RowSelect` [ char | cellstr ] - Selection of row names.
%
% * `ColSelect` [ char | cellstr ] - Selection of column names.
%
% * `Select` [ char | cellstr ] - Selection of names that will be applied
% to both rows and columns.
%
% Output arguments
% =================
%
% * `X` [ namedmat ] - Submatrix with named rows and columns.
%
% * `Pos` [ cell ] - `Pos{1}` is the vector of rows included in the
% submatrix `X`, `Pos{2}` is the vector of columns included in the
% submatrix `X`.
%
% Description
% ============
%
% Example
% ========

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

try
    ColSelect;
catch %#ok<CTCH>
    if iscell(RowSelect) && length(RowSelect) == 2 ...
            && iscell(RowSelect{1}) && iscell(RowSelect{2})
        ColSelect = RowSelect{2};
        RowSelect = RowSelect{1};
    else
        ColSelect = RowSelect;
    end
end

if ischar(RowSelect)
    RowSelect = regexp(RowSelect,'[\w\{\}\(\)\+\-]+','match');
end

if ischar(ColSelect)
    ColSelect = regexp(ColSelect,'[\w\{\}\(\)\+\-]+','match');
end

%--------------------------------------------------------------------------

removeLogFunc = @(x) regexprep(x,'log\((.*?)\)','$1');
rowSelect = removeLogFunc(RowSelect(:).');
colSelect = removeLogFunc(ColSelect(:).');
rowNames = removeLogFunc(This.Rownames);
colNames = removeLogFunc(This.Colnames);

nRowSelect = length(rowSelect);
nColSelect = length(colSelect);

rowPos = nan(1,nRowSelect);
colPos = nan(1,nColSelect);

for i = 1 : length(rowSelect)
    pos = find(strcmp(rowNames,rowSelect{i}),1);
    if ~isempty(pos)
        rowPos(i) = pos;
    end
end

for i = 1 : length(colSelect)
    pos = find(strcmp(colNames,colSelect{i}),1);
    if ~isempty(pos)
        colPos(i) = pos;
    end
end

doChkNotFound();

rowNames = This.rownames;
colNames = This.colnames;
This = double(This);
s = size(This);
This = This(:,:,:);
This = This(rowPos,colPos,:);
if length(s) > 2
    This = reshape(This,[nRowSelect,nColSelect,s(3:end)]);
end
This = namedmat(This,rowNames(rowPos),colNames(colPos));

Pos = {rowPos,colPos};

% Nested functions.

%**************************************************************************
    function doChkNotFound()
        nanRow = find(isnan(rowPos));
        nanCol = find(isnan(colPos));
        if isempty(nanRow) && isempty(nanCol)
            return
        end
        message = {};
        for ii = nanRow
            message{end+1} = 'row'; %#ok<AGROW>
            message{end+1} = RowSelect{ii}; %#ok<AGROW>
        end
        for ii = nanCol
            message{end+1} = 'column'; %#ok<AGROW>
            message{end+1} = ColSelect{ii}; %#ok<AGROW>
        end
        utils.error('namedmat', ...
            'This is not a valid %s name: ''%s''.', ...
            message{:});
    end % doChkNotFound().

end
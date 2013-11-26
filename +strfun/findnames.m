function [Pos,NotFound,Pos1] = findnames(List,Select,Pattern)
% findnames  Find positions of strings in a list.
%
% Syntax
% =======
%
%     [Pos,NotFound] = strfun.findnames(List,Select)
%
% Input arguments
% ================
%
% * `List` [ cellstr ] - List of items that will be searched.
%
% * `Select` [ cellstr | char ] List of items that will be looked for.
%
% Output arguments
% =================
%
% * `Pos` [ numeric ] - Positions of `Select` items in `List`; if some
% `Select` items are not found, the position will be `NaN`.
%
% * `NotFound` [ cellstr ] - List of `Select` items not found in `List`.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

if nargin < 3
   Pattern = '\w+';
end

if ischar(List)
   List = regexp(List,Pattern,'match');
end
List = List(:).';

if ischar(Select)
   Select = regexp(Select,Pattern,'match');
end
Select = Select(:);

%--------------------------------------------------------------------------

Pos = nan(size(Select));
for i = 1 : length(Select(:))
   tmp = strcmp(List,Select{i});
   if any(tmp)
      Pos(i) = find(tmp,1);
   end
end
NotFound = Select(isnan(Pos));
NotFound = NotFound(:).';

if nargout <= 2
    return
end

nList = length(List);
nSelect = length(Select);
List = List(ones(1,nSelect),:);
Select = Select(:,ones([1,nList]));
[i,j] = find(strcmp(List,Select));
Pos1 = nan(1,nSelect);
Pos1(i) = j;

end
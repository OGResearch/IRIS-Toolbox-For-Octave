function List = nonunique(List)
% nonunique  Non-unique entries in a list.
%
% Syntax
% =======
%
%     B = nonunique(A)
%
% Input arguments
% ================
%
% * `A` [ cellstr ] - Input list of strings that will be checked for
% non-unique entries.
%
% Output arguments
% =================
%
% * `B` [ cellstr ] - Output list of non-unique entries.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

[~,inx] = unique(List);
List(inx) = [];
if ~isempty(List)
    List = unique(List);
end

end
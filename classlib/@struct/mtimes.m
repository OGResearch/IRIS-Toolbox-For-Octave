function This = mtimes(This,List)
% mtimes  Keep only the database entries that are on the list.
%
% Syntax
% =======
%
%     D = D * List
%
% Input arguments
% ================
%
% * `D` [ struct ] - Input database.
%
% * `List` [ cellstr ] - List of entries that will be kept in the output
% database.
%
% Output arguments
% =================
%
% * `D` [ struct ] - Output database with only the input entries kept that
% are on included in `list`.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

pp = inputParser();
pp.addRequired('d',@isstruct);
pp.addRequired('list',@(x) iscellstr(x) || ischar(x));
pp.parse(This,List);

%--------------------------------------------------------------------------

if ischar(List)
    List = regexp(List,'\w+','match');
end

f = fieldnames(This).';
c = struct2cell(This).';
[fNew,inx] = intersect(f,List);
This = cell2struct(c(inx),fNew,2);

end

function This = minus(This,List)
% minus  Remove entries from a database.
%
% Syntax
% =======
%
%     D = D - Remove
%
% Input arguments
% ================
%
% * `D` [ struct ] - Input database from which some entries will be
% removed.
%
% * `Remove` [ char | cellstr ] - List of entries that will be removed from
% `D`.
%
% Output arguments
% =================
%
% * `D` [ struct ] - Output database with entries listed in `Remove`
% removed from it.
%
% Description
% ============
%
% This functio works the same way as the built-in function `rmfield` except
% it does not throw an error when some of the entries listed in `Remove`
% are not found in `D`.
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

pp = inputParser();
pp.addRequired('D',@isstruct);
pp.addRequired('List',@(x) iscellstr(x) || ischar(x));
pp.parse(This,List);

%--------------------------------------------------------------------------

if ischar(List)
    List = regexp(List,'\w+','match');
elseif isstruct(List)
    List = fieldnames(List);
end

f = fieldnames(This).';
c = struct2cell(This).';
[fNew,inx] = setdiff(f,List);
This = cell2struct(c(inx),fNew,2);

end

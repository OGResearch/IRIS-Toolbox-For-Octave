function This = mtimes(This,List)
% See help on dbase/dbmtimes.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

if false % ##### MOSW
pp = inputParser();
pp.addRequired('D',@isstruct);
pp.addRequired('List',@(x) iscellstr(x) || ischar(x));
pp.parse(This,List);
end

%--------------------------------------------------------------------------

if ischar(List)
    List = regexp(List,'\w+','match');
end

f = fieldnames(This).';
c = struct2cell(This).';
[fNew,inx] = intersect(f,List);
This = cell2struct(c(inx),fNew,2);

end
function This = minus(This,List)
% See help on dbase/dbminus.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

if true % ##### MOSW
pp = inputParser();
pp.addRequired('D',@isstruct);
pp.addRequired('List',@(x) iscellstr(x) || ischar(x));
pp.parse(This,List);
end

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
function D = plus(D1,D2)
% See help on dbase/dbplus.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

if is.matlab
pp = inputParser();
pp.addRequired('D1',@isstruct);
pp.addRequired('D2',@isstruct);
pp.parse(D1,D2);
end

%--------------------------------------------------------------------------

names = [fieldnames(D1);fieldnames(D2)];
values = [struct2cell(D1);struct2cell(D2)];
[names,inx] = unique(names,'last');
D = cell2struct(values(inx),names);

end
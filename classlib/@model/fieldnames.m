function list = fieldnames(m)
% fieldnames  [Not a public function] Alphabetical list of names that can be used in dot-references.
%
% Backend IRIS function.
% No help provided.


% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%**************************************************************************

elist = m.name(m.nametype == 3);
list = {};
for i = 1 : length(elist)
   list{end+1} = ['std_',elist{i}];
   for j = 1 : length(elist)
      if i == j
         continue
      end
      list{end+1} = ['corr_',elist{j},'__',elist{i}];
   end
end
list = [list,m.name];
list = sort(list);

end

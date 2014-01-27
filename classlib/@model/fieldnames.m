function List = fieldnames(This)
% fieldnames  [Not a public function] Alphabetical list of names that can be used in dot-references.
%
% Backend IRIS function.
% No help provided.


% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

elist = This.name(This.nametype == 3);
List = {};
for i = 1 : length(elist)
   List{end+1} = ['std_',elist{i}]; %#ok<AGROW>
   for j = 1 : length(elist)
      if i == j
         continue
      end
      List{end+1} = ['corr_',elist{j},'__',elist{i}]; %#ok<AGROW>
   end
end
List = [List,This.name];
List = sort(List);

end

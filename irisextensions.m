function irisextensions()
% irisextensions  Associate IRIS extensions with Matlab editor.
%
% Backed IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%**************************************************************************

preffile = fullfile(prefdir(),'matlab.prf');
if ~exist(preffile,'file')
   return
end

list = irisget('extensions');
try
   fid = fopen(preffile,'r');
   if fid == -1
      return
   end
   pref = char(transpose(fread(fid,'char')));
   fclose(fid);
   currentList = regexp(pref,'Editorm-Ext=S(.*?)\s*\n','tokens','once');
   currentList = regexp(currentList{1},'\w+','match');
   newList = currentList;
   dosave = false;
   for i = 1 : numel(list)
      if ~any(strcmp(list{i},newList))
         newList{end+1} = list{i};
         dosave = true;
      end
   end
   if dosave
      newList = sprintf('%s;',newList{:});
      newList = newList(1:end-1);
      pref = regexprep(pref, ...
         'Editorm-Ext=S(.*?)(\s*)\n', ...
         ['Editorm-Ext=S',newList,'$2\n'], ...
         'once');
      fid = fopen(preffile,'w+');
      fwrite(fid,pref,'char');
      fclose(fid);
   end
catch
   try
      fclose(fid);
   end
end

end

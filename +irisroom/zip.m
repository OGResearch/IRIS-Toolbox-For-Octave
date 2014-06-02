function zip(Archive,Suffix)
% zip  [Not a public function] Zip IRIS for distribution.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

Archive; %#ok<VUNUS>

try
    Suffix; %#ok<VUNUS>
catch
    Suffix = '';
end

Ver = irisroom.updateversion(Suffix);

root = irisroot();
list = dir(root);
list = {list.name};
nList = length(list);
remove = false(1,nList);
for i = 1 : nList
    if isempty(list{i}) || list{i}(1) == '.'
        remove(i) = true;
        continue
    end
    list{i} = fullfile(root,list{i});
end
list(remove) = [];

p = fullfile(Archive,['IRIS_Tbx_',Ver,'.zip']);
if exist(p,'file')
    disp(['Deleting ',p]);
    disp(' ');
    delete(p);
end
list = zip(p,list);

disp(char(list));
disp(' ');
disp(p);

end
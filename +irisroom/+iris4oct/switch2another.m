function switch2another()

path2iris = pwd();
switchFile = fullfile(path2iris,'+irisroom','iris4oct','.lastSwitchTo');

addpath(fullfile(path2iris,'utils'));

if exist(switchFile,'file')
  syst = file2char(fullfile(path2iris,'+irisroom','iris4oct','.lastSwitch'));
  toOct = isequal(syst,'octave');
else
  error('No ".lastSwitch" file. Cannot decide how to switch.');
end

lst = irisroom.iris4oct.irisfulldirlist('files',true,'fileExt','.m');
for ix = 1 : numel(lst)
  filename = lst{ix};
  % parse ">>>>> MOSW" occurrences
  content = file2char(filename);
  content = regexprep(content,'(.*)( % >>>>> MOSW )(.*?)(\n.*)','$3$2$1$4');
  char2file(content,filename);
  % parse "##### MOSW" occurrences
  content = file2char(filename);
  if toOct
    content = strrep(content,'true % ##### MOSW','false % ##### MOSW');
  else
    content = strrep(content,'false % ##### MOSW','true % ##### MOSW');
  end
  char2file(content,filename);
end
rmpath(fullfile(path2iris,'utils'));

if toOct
  char2file('octave',switchFile);
else
  char2file('matlab',switchFile);
end

end
function switch2another()

path2iris = pwd();
switchFile = fullfile(path2iris,'+irisroom','+iris4oct','.lastSwitchTo');

addpath(fullfile(path2iris,'utils'));

if exist(switchFile,'file')
  toOctave = isequal(file2char(switchFile),'matlab');
  toMatlab = isequal(file2char(switchFile),'octave');
  if ~toOctave && ~toMatlab
    error('Wrong content of ".lastSwitchTo" file!');
  end
else
  error('No ".lastSwitchTo" file! Cannot decide how to switch.');
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
  if toOctave
    content = strrep(content,'true % ##### MOSW','false % ##### MOSW');
  else
    content = strrep(content,'false % ##### MOSW','true % ##### MOSW');
  end
  char2file(content,filename);
end

if toOctave
  char2file('octave',switchFile);
else
  char2file('matlab',switchFile);
end

rmpath(fullfile(path2iris,'utils'));
end
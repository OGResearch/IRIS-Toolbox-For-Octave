%% look for @blabla.blabla
%{
pattern = '[^\w]@\w+?\.\w+';

lst = irisroom.iris4oct.irisfulldirlist('files',true,'fileExt','.m');

files = struct('name',[],'lines',[]);

for ix = 1 : numel(lst)
    [flg, lines] = irisroom.iris4oct.isPatternInFile(lst{ix},pattern);
    if flg
        fprintf('[file]: %s\n\t[lines]:\n',lst{ix});
        fprintf('\t%s\n',lines{:});
        files(end+1).name = lst{ix}; %#ok<SAGROW>
        files(end).lines = lines;
    end
end
%}
return

%% kick inputParser workaround out of iris_clone

lst = irisroom.iris4oct.irisfulldirlist('files',true,'fileExt','.m'); %#ok<UNRCH>
files = {};
for ix = 1 : numel(lst)
    flg = irisroom.iris4oct.isPatternInFile(lst{ix},'=\s*inputParser(');
    if flg
        files = [files,lst{ix}];
    end
end

for ix = 1 : numel(files)
    irisroom.iris4oct.parseFile4inputParser_back(files{ix});
end

return
function lst = irisfulldirlist(varargin)

root = irisroot();

if ~ischar(root) && numel(root) > 1
    error('More than one IRIS is on your path!');
end

lst = xxGetCurDirSubs(root,'exclude',{{'^\.','^\-','+Contents','+iris4oct'}},varargin{:});

end

function lst = xxGetCurDirSubs(path,varargin)

opt = struct(varargin{:});

files = false;
if isfield(opt,'files')
    files = opt.files;
end

fileExt = {''};
if isfield(opt,'fileExt')
    fileExt = opt.fileExt;
    if ischar(fileExt)
        fileExt = {fileExt};
    end
end

path = fullfile(path,filesep);

d = dir(path);
names = {d.name}';
dirIx = [d.isdir]';
lst2check = names(dirIx);

if isfield(opt,'exclude')
    doExclude();
end

if files
    fileExtPtn = strcat('.*',strrep(fileExt,'.','\.'),'$');
    extIx = cellfun(@(x)any(~cellfun(@isempty,regexp(x,fileExtPtn))), ...
        names);
    lst = fullfile(path,names(~dirIx & extIx));
else
    lst = path;
end

if ischar(lst)
    lst = {lst};
end

lst2check = strcat(path,lst2check);

for ix = 1 : numel(lst2check)
    lst = [lst; xxGetCurDirSubs(lst2check{ix},varargin{:})]; %#ok<AGROW>
end

    function doExclude()
        keep = true(1,numel(lst2check));
        for xix = 1:numel(opt.exclude)
             ix2excl = cellfun(@(x)~isempty(x), ...
                 regexp(lst2check,opt.exclude{xix}));
             keep(ix2excl) = false;
        end
        lst2check = lst2check(keep);
    end

end
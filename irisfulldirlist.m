function lst = irisfulldirlist()

root = irisroot();

if ~ischar(root) && numel(root) > 1
    error('More than one IRIS is on your path!');
end

lst = xxGetCurDirSubs(root,'exclude',{{'^\.','^\-','+Contents'}});

end

function lst = xxGetCurDirSubs(path,varargin)

opt = struct(varargin{:});

lst = {fullfile(path,filesep)};

d = dir(path);
names = {d.name};
dirIx = [d.isdir];
lst2check = names(dirIx);

if isfield(opt,'exclude')
    doExclude();
end

for ix = 1 : numel(lst2check)
    disp(lst2check{ix})
    lst = [lst,xxGetCurDirSubs(lst2check{ix},'exclude',{{'^\.'}})]; %#ok<AGROW>
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
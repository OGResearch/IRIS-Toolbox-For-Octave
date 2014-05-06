function flag = myisa(this,cls)

if ismatlab || ~isobject(this)
    flag = isa(this,cls);
else
    mc = metaclass(this);
    derivFrom = mc.SuperClassList;
    derivFromList = cell(1,numel(derivFrom));
    for ix = 1:numel(derivFrom)
        derivFromList{ix} = derivFrom{ix}.Name;
    end
    flag = any(strcmp(cls,[derivFromList,mc.Name]));
end

end
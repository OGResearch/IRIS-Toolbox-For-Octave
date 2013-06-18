function Flag = iscellfunc(X)
Flag = iscell(X) && all(cellfun(@(x) isa(x,'function_handle'),X(:)));
end
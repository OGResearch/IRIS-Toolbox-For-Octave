function flag = islogicalscalar(x)
flag = islogical(x) && numel(x) == 1;
end
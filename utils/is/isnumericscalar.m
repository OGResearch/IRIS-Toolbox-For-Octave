function flag = isnumericscalar(x)
flag = isnumeric(x) && numel(x) == 1;
end
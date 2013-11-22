function Flag = isintscalar(X)
Flag = isnumeric(X) && length(X) == 1 && round(X) == X;
end
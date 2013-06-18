function Flag = isanychari(X,List)
Flag = ischar(X) && iscellstr(List) && any(strcmpi(X,List));
end
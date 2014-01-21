function flag = isanychar(x,list)
flag = ischar(x) && any(strcmp(x,list));
end
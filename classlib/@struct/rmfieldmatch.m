function s = rmfieldmatch(s,pattern)

list = fieldnames(s);
index = strfun.matchindex(list,pattern);
s = rmfield(s,list(index));

end
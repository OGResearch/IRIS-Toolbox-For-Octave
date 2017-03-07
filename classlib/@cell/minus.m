function x = minus(x,y)
if ischar(x)
  x = {x};
end
if ischar(y)
  y = {y};
end
if isstruct(y)
   y = fieldnames(y);
end
[x,index] = setdiff(x,y);
[index,backindex] = sort(index);
x = x(backindex);
end
function flag = isrvar(x)
flag = isvar(x) && isempty(x.B);
end
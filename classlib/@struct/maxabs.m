function x = maxabs(x,y)
if exist('y','var')
    x = dbfun(@maxabs,x,y);
else
    x = dbfun(@maxabs,x);
end
end
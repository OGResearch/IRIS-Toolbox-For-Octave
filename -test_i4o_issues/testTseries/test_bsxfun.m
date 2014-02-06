x = tseries(qq(1,1):qq(3,2),sin(1:10)) ;
assert(double(bsxfun(@max, x, 0)), bsxfun(@max, double(x), 0)) ;

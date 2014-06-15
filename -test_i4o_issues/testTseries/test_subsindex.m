x = tseries(qq(1,1):qq(3,2),sin(1:10)) ;
myassert(x(:), double(x)) ;

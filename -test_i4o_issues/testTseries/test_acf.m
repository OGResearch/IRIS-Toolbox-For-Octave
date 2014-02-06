absTol = eps()^(2/3);
x = tseries(qq(1,1):qq(3,2),sin(1:10)) ;
assert(acf(x), var(x), absTol) ;

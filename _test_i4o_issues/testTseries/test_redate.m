absTol = eps()^(2/3);

x = tseries(qq(1,1):qq(3,2),sin(1:10)) ;

observ = range(redate(x,qq(1,1),qq(2,2))) ;
expect = qq(2,2) : qq(4,3) ;
myassert(observ, expect, absTol);

absTol = eps()^(2/3);

x = tseries(qq(1,1):qq(3,2),sin(1:10)) ;

myassert(mean(x), 0.141118837121801, absTol) ;

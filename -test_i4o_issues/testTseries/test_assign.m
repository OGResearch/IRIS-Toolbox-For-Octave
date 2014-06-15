x = tseries() ;
x(1:5) = 2 : 6 ;

myassert(double(x), (2:6)') ;
myassert(range(x), 1:5) ;

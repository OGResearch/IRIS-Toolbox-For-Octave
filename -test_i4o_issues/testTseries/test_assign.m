x = tseries() ;
x(1:5) = 2 : 6 ;

assert(double(x), (2:6)') ;
assert(range(x), 1:5) ;

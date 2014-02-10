myassert(isscalar(tseries(1, 1)), true) ;
myassert(isscalar(tseries(1:2, 1)), true) ;
myassert(isscalar(tseries(1, [1 2])), false) ;

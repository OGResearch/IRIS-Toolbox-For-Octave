assert(isscalar(tseries(1, 1)), true) ;
assert(isscalar(tseries(1:2, 1)), true) ;
assert(isscalar(tseries(1, [1 2])), false) ;

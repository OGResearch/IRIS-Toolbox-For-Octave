toSolve = true;
setup4tests;

m = mInit ;
mm = mInitSolved ;

myassert( issolved(model()), false) ;
myassert( issolved(m), false) ;
myassert( chksstate(m,'error=', false, 'warning=', false), false) ;
myassert( issolved(mm), true) ;
myassert( chksstate(mm,'error=', false, 'warning=', false), true) ;
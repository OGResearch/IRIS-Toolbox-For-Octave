toSolve = true;
setup4tests;

m = mInit ;
mm = mInitSolved ;

myassert(issolved(model()), false) ;
myassert(issolved(m), false) ;
myassert(issolved(mm), true) ;
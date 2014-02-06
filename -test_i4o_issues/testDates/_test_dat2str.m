observ = dat2char(qq(2010,1)) ;
expect = '2010Q1' ;
assert(observ, expect) ;

observ = dat2char(mm(2010,1)) ;
expect = '2010M01' ;
assertEqual(This, actual, expected) ;

observ = dat2char(qq(2010,1)) ;
expect = '2010Q1' ;
myassert(observ, expect) ;

observ = dat2char(mm(2010,1)) ;
expect = '2010M01' ;
myassert(observ, expect) ;

observ = dat2char(yy(2010)) ;
expect = '2010Y' ;
myassert(observ, expect) ;

observ = dat2char(qq(2010,1)) ;
expect = '2010Q1' ;
myassert(observ, expect) ;

observ = dat2char(qq(2010,1)) ;
expect = '2010Q1' ;
myassert(observ, expect) ;

observ = dat2char(qq(2010,1), ...
    'dateFormat=','YYYY-MM-EE') ;
expect = '2010-01-31' ;
myassert(observ, expect) ;

observ = dat2char(qq(2010,1), ...
    'dateFormat=','YYYY-MM-WW') ;
expect = '2010-01-29' ;
myassert(observ, expect) ;

observ = dat2char(mm(2010,1)) ;
expect = '2010M01' ;
myassert(observ, expect) ;

observ = dat2char(ww(2002,1)) ;
expect = '2002W01';
myassert(observ, expect) ;

observ = dat2char(ww(2002,1), ...
    'dateFormat=','YYYY-MM') ;
expect = '2002-01';
myassert(observ, expect) ;

observ = dat2char(ww(2002,1), ...
    'dateFormat=','$YYYY-MM-DD') ;
expect = '2002-01-03';
myassert(observ, expect) ;

observ = dat2char(dd(2002,1,1), ...
    'dateFormat=','$YYYY-Mmm-DD') ;
expect = '2002-Jan-01';
myassert(observ, expect) ;
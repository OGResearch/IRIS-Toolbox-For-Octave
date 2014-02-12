observ = dat2char(str2dat('01-2010', ...
    'dateformat=', 'MM-YYYY', 'freq=', 12)) ;
expect = '2010M01' ;
myassert(observ, expect) ;

observ = dat2char(str2dat('01-2010', ...
    'dateformat=', 'MM-YYYY', 'freq=', 4)) ;
expect = '2010Q1' ; 
myassert(observ, expect) ;

observ = dat2char(str2dat('01-2010', ...
    'dateformat=', 'MM-YYYY', 'freq=', 1)) ;
expect = '2010Y' ;
myassert(observ, expect);


observ = dat2char(str2dat('01-2010', ...
    'dateFormat=', 'MM-YYYY', 'freq=', 12)) ;
expect = '2010M01' ;
myassert(observ, expect) ;

observ = dat2char(str2dat('01-2010', ...
    'dateFormat=', 'MM-YYYY', 'freq=', 4)) ;
expect = '2010Q1' ; 
myassert(observ, expect) ;

observ = dat2char(str2dat('01-2010', ...
    'dateFormat=', 'MM-YYYY', 'freq=', 1)) ;
expect = '2010Y' ;
myassert(observ, expect) ;

observ = dat2char(str2dat('2001-12-31', ...
    'dateFormat=', '$YYYY-MM-DD','freq=', 52)) ;
expect = '2002W01';
myassert(observ, expect) ;
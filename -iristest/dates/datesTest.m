function Tests = datesTest()

Tests = functiontests(localfunctions) ;

end


%**************************************************************************
function testDat2str(This) %#ok<*DEFNU>

actual = dat2char(yy(2010)) ;
expected = '2010Y' ;
assertEqual(This, actual, expected) ;

actual = dat2char(qq(2010,1)) ;
expected = '2010Q1' ;
assertEqual(This, actual, expected) ;

actual = dat2char(qq(2010,1)) ;
expected = '2010Q1' ;
assertEqual(This, actual, expected) ;

actual = dat2char(qq(2010,1), ...
    'dateFormat=','YYYY-MM-EE') ;
expected = '2010-01-31' ;
assertEqual(This, actual, expected) ;

actual = dat2char(qq(2010,1), ...
    'dateFormat=','YYYY-MM-WW') ;
expected = '2010-01-29' ;
assertEqual(This, actual, expected) ;

actual = dat2char(mm(2010,1)) ;
expected = '2010M01' ;
assertEqual(This, actual, expected) ;

actual = dat2char(ww(2002,1)) ;
expected = '2002W01';
assertEqual(This, actual, expected) ;

actual = dat2char(ww(2002,1), ...
    'dateFormat=','YYYY-MM') ;
expected = '2002-01';
assertEqual(This, actual, expected) ;

actual = dat2char(ww(2002,1), ...
    'dateFormat=','$YYYY-MM-DD') ;
expected = '2001-12-31';
assertEqual(This, actual, expected) ;

actual = dat2char(dd(2002,1,1), ...
    'dateFormat=','$YYYY-Mmm-DD') ;
expected = '2002-Jan-01';
assertEqual(This, actual, expected) ;


end % testDat2str()



%**************************************************************************
function testStr2dat(This)

actual = dat2char(str2dat('01-2010', ...
    'dateFormat=', 'MM-YYYY', 'freq=', 12)) ;
expected = '2010M01' ;
assertEqual(This, actual, expected) ;

actual = dat2char(str2dat('01-2010', ...
    'dateFormat=', 'MM-YYYY', 'freq=', 4)) ;
expected = '2010Q1' ; 
assertEqual(This, actual, expected) ;

actual = dat2char(str2dat('01-2010', ...
    'dateFormat=', 'MM-YYYY', 'freq=', 1)) ;
expected = '2010Y' ;
assertEqual(This, actual, expected) ;

actual = dat2char(str2dat('2001-12-31', ...
    'dateFormat=', '$YYYY-MM-DD','freq=', 52)) ;
expected = '2002W01';
assertEqual(This, actual, expected) ;

end % testStd2dat()

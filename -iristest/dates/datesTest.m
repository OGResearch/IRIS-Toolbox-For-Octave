function Tests = datesTest()

Tests = functiontests(localfunctions) ;

end


%**************************************************************************
function testDat2str(This) %#ok<*DEFNU>

actual = dat2char(qq(2010,1)) ;
expected = '2010Q1' ;
assertEqual(This, actual, expected) ;

actual = dat2char(mm(2010,1)) ;
expected = '2010M01' ;
assertEqual(This, actual, expected) ;

end % testDat2str()


%**************************************************************************
function testStr2dat(This)

actual = dat2char(str2dat('01-2010', ...
    'dateformat=', 'MM-YYYY', 'freq=', 12)) ;
expected = '2010M01' ;
assertEqual(This, actual, expected) ;

actual = dat2char(str2dat('01-2010', ...
    'dateformat=', 'MM-YYYY', 'freq=', 4)) ;
expected = '2010Q1' ; 
assertEqual(This, actual, expected) ;

actual = dat2char(str2dat('01-2010', ...
    'dateformat=', 'MM-YYYY', 'freq=', 1)) ;
expected = '2010Y' ;
assertEqual(This, actual, expected);

end % testStd2dat()

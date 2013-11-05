function Tests = csvDataTest()

Tests = functiontests(localfunctions) ;

end


%**************************************************************************
function testMissingObs(This) %#ok<*DEFNU>

actDbase = dbload('testMissingObs.csv') ;

range = qq(2000,1) : qq(2000,4) ;
expDbase = struct() ;
expDbase.x = tseries(range, [1;2; NaN; NaN]) ;
expDbase.y = tseries(range, [10+10i; NaN+NaN*1i; 30; NaN+0i]) ;
expDbase.z = tseries(range, [100; NaN; 300; 400]) ;

assertEqual(This, actDbase, expDbase) ;

end % testMissingObs()

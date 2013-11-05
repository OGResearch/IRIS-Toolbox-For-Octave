function Tests = logDistTest()

Tests = functiontests(localfunctions) ;

end


%**************************************************************************
function setupOnce(This) %#ok<*DEFNU>
This.TestData.absTol = eps() ;
end % setupOnce()


%**************************************************************************
function testNormalScalar(This)

if license('test','statistics_toolbox')    
    f = logdist.normal(0, 1) ;
    actValue = f(2, 'pdf');
    expValue = normpdf(2) ;
    assertEqual(This, actValue, expValue, 'absTol', This.TestData.absTol) ;
    
    Mu = 1 ;
    Sig = 2 ;
    f = logdist.normal(Mu, Sig) ;
    actValue = f(2,'pdf') ;
    expValue = normpdf(2, Mu, Sig);
    assertEqual(This,actValue, expValue, 'absTol', This.TestData.absTol) ;
end

end % testNormalScalar()


%**************************************************************************
function testTScalar(This)

if license('test','statistics_toolbox')
    df = 10 ;
    f = logdist.t(0, 1, df) ;
    actValue = f(2, 'pdf') ;
    expValue = tpdf(2, df) ;
    assertEqual(This, actValue, expValue, 'absTol', This.TestData.absTol) ;
end

end % testTScalar()


%**************************************************************************
function testChiSquare(This)

if license('test','statistics_toolbox')
    df = 3 ;
    val = 2 ;
    f = logdist.chisquare(df) ;
    actValue = f(val, 'pdf');
    expValue = chi2pdf(val, df) ;
    assertEqual(This, actValue, expValue, 'absTol', This.TestData.absTol) ;
end

end % testChiSquare()

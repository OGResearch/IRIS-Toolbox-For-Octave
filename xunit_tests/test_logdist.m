% test_logdist.m

function test_logdist
initTestSuite;
end

function test_normal_scalar %#ok<*DEFNU>
if license('test','statistics_toolbox')
    fh_sn = logdist.normal(0,1) ;
    assertElementsAlmostEqual( normpdf(2), fh_sn(2,'pdf') ) ;
    Mu = 1 ;
    Sig = 2 ;
    fh = logdist.normal(Mu,Sig) ;
    assertElementsAlmostEqual( normpdf(2,Mu,Sig), fh(2,'pdf') ) ;
end
end

function test_t_scalar
if license('test','statistics_toolbox')
    df = 10 ;
    fh_st = logdist.normal(0, 1, df) ;
    assertElementsAlmostEqual( tpdf(2,df), fh_st(2,'pdf') ) ;
end
end

function test_chisquare
if license('test','statistics_toolbox')
    df = 3 ;
    val = 2 ;
    fh = logdist.chisquare( df ) ;
    assertElementsAlmostEqual( pdf('chi2' ,val, df), fh(val, 'pdf') ) ;
end
end
df = 10 ;
f = logdist.t(0, 1, df) ;
actValue = f(2, 'pdf') ;
expValue = tpdf(2, df) ;
myassert(actValue, expValue, eps()) ;

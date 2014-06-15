df = 3 ;
val = 2 ;
f = logdist.chisquare(df) ;
actValue = f(val, 'pdf');
expValue = chi2pdf(val, df) ;
myassert(actValue, expValue, eps()) ;

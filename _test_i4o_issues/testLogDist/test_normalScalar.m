f = logdist.normal(0, 1) ;
actValue = f(2, 'pdf');
expValue = normpdf(2) ;
myassert(actValue, expValue, eps()) ;

Mu = 1 ;
Sig = 2 ;
f = logdist.normal(Mu, Sig) ;
actValue = f(2,'pdf') ;
expValue = normpdf(2, Mu, Sig);
myassert(actValue, expValue,  eps()) ;

eqtn = 'K * X^2 * normcdf(K*X)';

wrt = struct();
wrt.X = xxBetween(0.4,0.6);
wrt.K = xxBetween(-5,5);

expFunc = @(X,K) [ ...
    K*(2*X*normcdf(K*X) + X^2*sydney.d(@normcdf,1,K*X)*K); ...
    X^2*(normcdf(K*X) + K*sydney.d(@normcdf,1,K*X)*X); ...
];

[actValue1,actValue2,expValue] = xxEval(eqtn,wrt,expFunc);

absTol = eps()^(2/3);
myassert(actValue1,expValue,absTol);
myassert(actValue2,expValue,absTol);
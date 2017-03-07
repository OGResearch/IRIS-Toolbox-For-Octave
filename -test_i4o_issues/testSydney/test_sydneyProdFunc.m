eqtn = '-Y + A * (N - (1-0.6)*N0)^0.6 * K^(1-0.6)';

wrt = struct();
wrt.Y = xxBetween(0.5,5);
wrt.A = xxBetween(0.5,5);
wrt.N = xxBetween(0.5,5);
wrt.N0 = xxBetween(0.5,5);
wrt.K = xxBetween(0.1,0.9);

gam = 0.6;
expFunc = @(Y,A,N,N0,K) [ ...
    -1; ...
    (N - (1-gam)*N0)^gam * K^(1-gam); ...
    A * gam*(N - (1-gam)*N0)^(gam-1) * K^(1-gam); ...
    A * gam*(N - (1-gam)*N0)^(gam-1) * (gam-1) * K^(1-gam); ...
    A * (N - (1-gam)*N0)^gam * (1-gam)*K^(-gam); ...
    ];

[actValue1,actValue2,expValue] = xxEval(eqtn,wrt,expFunc);

absTol = eps()^(2/3);
myassert(actValue1,expValue,absTol);
myassert(actValue2,expValue,absTol);
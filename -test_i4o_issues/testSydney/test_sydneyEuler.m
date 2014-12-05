eqtn = '-(P*Lambda) + (1-chi)/(Y - chi*H)';

wrt = struct();
wrt.P = xxBetween(0.5,5);
wrt.Lambda = xxBetween(0.5,5);
wrt.Y = xxBetween(0.5,5);
wrt.H = xxBetween(0.5,5);
wrt.chi = xxBetween(0.1,0.9);

expFunc = @(P,Lambda,Y,H,chi) [ ...
    -Lambda; ...
    -P; ...
    -(1-chi)/(Y - chi*H)^2; ...
    chi*(1-chi)/(Y - chi*H)^2; ...
    (-(Y-chi*H) + (1-chi)*H) / (Y - chi*H)^2; ...
    ];

[actValue1,actValue2,expValue] = xxEval(eqtn,wrt,expFunc);

absTol = eps()^(2/3);
myassert(actValue1,expValue,absTol);
myassert(actValue2,expValue,absTol);
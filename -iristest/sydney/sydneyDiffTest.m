function Tests = sydneyDiffTest()

Tests = functiontests(localfunctions) ;

end


%**************************************************************************
function setupOnce(This) %#ok<*DEFNU>

This.TestData.absTol = eps()^(2/3);
This.TestData.N = 1;

end % setupOnce()


%**************************************************************************
function testEuler(This)

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

[actValue1,actValue2,expValue] = xxEval(This,eqtn,wrt,expFunc);

assertEqual(This,actValue1,expValue,'absTol',This.TestData.absTol);
assertEqual(This,actValue2,expValue,'absTol',This.TestData.absTol);

end % testEuler()


%**************************************************************************
function testProdFunc(This)

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

[actValue1,actValue2,expValue] = xxEval(This,eqtn,wrt,expFunc);

assertEqual(This,actValue1,expValue,'absTol',This.TestData.absTol);
assertEqual(This,actValue2,expValue,'absTol',This.TestData.absTol);

end % testProdFunc()


%**************************************************************************
function testNormCdf(This)

eqtn = 'K * X^2 * normcdf(K*X)';

wrt = struct();
wrt.X = xxBetween(0.4,0.6);
wrt.K = xxBetween(-5,5);

expFunc = @(X,K) [ ...
    K*(2*X*normcdf(K*X) + X^2*sydney.d(@normcdf,1,K*X)*K); ...
    X^2*(normcdf(K*X) + K*sydney.d(@normcdf,1,K*X)*X); ...
];

[actValue1,actValue2,expValue] = xxEval(This,eqtn,wrt,expFunc);

assertEqual(This,actValue1,expValue,'absTol',This.TestData.absTol);
assertEqual(This,actValue2,expValue,'absTol',This.TestData.absTol);

end % testNormCdf()


%**************************************************************************
function [ActValue1,ActValue2,ExpValue] = xxEval(This,Eqtn,Wrt,ExpFunc)

N = This.TestData.N;
wrtList = fieldnames(Wrt);
nWrt = length(wrtList);
wrtCharList = sprintf('%s,',wrtList{:});
wrtCharList(end) = '';
z = sydney(Eqtn,wrtList);

if ismatlab
    s2fH = @str2func;
else
    s2fH = @mystr2func;
end

% En-bloc derivatives.
dz1 = diff(z,'enbloc',wrtList);
dz1 = char(dz1);
actFunc1 = s2fH(['@(',wrtCharList,') ',char(dz1)]);

% Separate derivatives.
dz2 = diff(z,'separate',wrtList);
for i = 1 : nWrt
    dz2{i} = char(dz2{i});
end
actFunc2 = s2fH(['@(',wrtCharList,') [',sprintf('%s;',dz2{:}),']']);

ActValue1 = nan(nWrt,N);
ActValue2 = nan(nWrt,N);
ExpValue = nan(nWrt,N);

for i = 1 : N
    while true
        % Make sure the random values don't produce NaNs or Infs when evaluated on
        % the true function.
        wrtArg = cell(1,nWrt);
        for j = 1 : nWrt
            name = wrtList{j};
            if isnumeric(Wrt.(name))
                wrtArg{j} = Wrt.(name);
            else
                wrtArg{j} = Wrt.(name)();
            end
        end
        ExpValue(:,i) = ExpFunc(wrtArg{:});
        if all(isfinite(ExpValue(:,i)))
            break
        end
    end
    ActValue1(:,i) = actFunc1(wrtArg{:});
    ActValue2(:,i) = actFunc2(wrtArg{:});
end

end % xxEval()

%**************************************************************************
function Y = xxBetween(L,U)
Y = @() L + rand*(U - L);
end % xxBetween()
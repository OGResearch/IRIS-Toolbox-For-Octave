absTol = eps()^(2/3);

a = tseries(qq(1,1),1);
b = tseries(qq(1,1),2);

observ = double([a, b]);
expect = [double(a), double(b)];

myassert(observ, expect, absTol);

b = tseries(qq(1,2),2);
observ = double([a; b]);
expect = [double(a); double(b)];

myassert(observ, expect, absTol);

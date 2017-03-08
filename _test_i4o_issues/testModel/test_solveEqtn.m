m = model('testSolveEqtn.model','linear=',true);
m.a = 11;
m.b = 12;
m.c = 13;
m.A = 21;
m.B = 22;
m.C = 23;
m = solve(m);
[T,R,K,Z,H,D] = sspace(m);

m1 = m;
m1.a = 51;
m1.b = 17;
m1.c = 100;
m1.A = -6;
m1.B = 50;
m1.C = 4;
m2 = m1;

m1 = solve(m1,'eqtn=','transition');
[T1,R1,K1,Z1,H1,D1] = sspace(m1);

myassertNot(T1,T);
myassertNot(R1,R);
myassertNot(K1,K);
myassert(Z1,Z);
myassert(H1,H);
myassert(D1,D);

m2 = solve(m2,'eqtn=','measurement');
[T2,R2,K2,Z2,H2,D2] = sspace(m2);

myassert(T2,T);
myassert(R2,R);
myassert(K2,K);
myassertNot(Z2,Z);
myassertNot(H2,H);
myassertNot(D2,D);
m = model('testLinearSystem.model','linear=',true);
m4 = model('testLinearSystem4.model','linear=',true);

m.a = 2*4;
m.b = 3*4;
m.c = 4*4;
m.d = 5*4;

m4.a = 2;
m4.b = 3;
m4.c = 4;
m4.d = 5;

[actA,actB,actC] = system(m);
[actA4,actB4,actC4] = system(m4,'sparse=',true);

expA = zeros(2);
expA(1,1) = -1;
expA(2,2) = -1;

expB = zeros(2);
expB(1,1) = 8;
expB(2,2) = 16;

expC = zeros(2,1);
expC(1,1) = 16;
expC(2,1) = -120;

myassert(actA,expA);
myassert(actB,expB);
myassert(actC,expC);
myassert(actA4,sparse(expA));
myassert(actB4,sparse(expB));
myassert(actC4,expC);
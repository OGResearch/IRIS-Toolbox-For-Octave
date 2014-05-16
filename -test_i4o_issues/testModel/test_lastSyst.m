m = model('testLastSyst.model','linear=',true);
m.a = 11;
m.b = 12;
m.c = 13;
m = solve(m);
get(m,'lastSyst');
s = get(m,'lastSyst');

actDerv = nonzeros(s.derv.f);
expDerv = [-11;-12;-13];
myassert(actDerv,expDerv);

m.a = 110;
solve(m);
actDerv = nonzeros(s.derv.f);
expDerv = [-110;-12;-13];
myassert(actDerv,expDerv);

m.b = 120;
solve(m);
actDerv = nonzeros(s.derv.f);
expDerv = [-110;-120;-13];
myassert(actDerv,expDerv);

m.c = 130;
solve(m);
actDerv = nonzeros(s.derv.f);
expDerv = [-110;-120;-130];
myassert(actDerv,expDerv);
setup4tests;

D = struct();
D.A = d;
D.B = d;
v = VAR({'x','y','z'}, ...
    'exogenous=',{'a','b'}, ...
    'groups=',{'A','B'});
[v,vd] = estimate(v,D,range,'order=',2);
s = simulate(v,vd,range(3:end));
c = simulate(v,vd,range(3:end),'contributions=',true);
myassert(double(sum(c.A.x,2)),double(s.A.x),1e-14);
myassert(double(sum(c.A.y,2)),double(s.A.y),1e-14);
myassert(double(sum(c.A.z,2)),double(s.A.z),1e-14);
myassert(double(sum(c.B.x,2)),double(s.B.x),1e-14);
myassert(double(sum(c.B.y,2)),double(s.B.y),1e-14);
myassert(double(sum(c.B.z,2)),double(s.B.z),1e-14);
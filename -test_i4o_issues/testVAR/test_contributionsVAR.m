setup4tests;
nPer = length(range);

v = VAR({'x','y','z'});
[v,vd] = estimate(v,d,range,'order=',2);
s = simulate(v,vd,range(3:end));
c = simulate(v,vd,range(3:end),'contributions=',true);
myassert(double(sum(c.x,2)), double(s.x), 1e-14);
myassert(double(sum(c.y,2)),double(s.y),1e-14);
myassert(double(sum(c.z,2)),double(s.z),1e-14);
myassert(double(c.x{:,end}),zeros(nPer,1));
myassert(double(c.y{:,end}),zeros(nPer,1));
myassert(double(c.z{:,end}),zeros(nPer,1));
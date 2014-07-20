function Tests = VARTest()
Tests = functiontests(localfunctions);
end
%#ok<*DEFNU>


%**************************************************************************


function setupOnce(This)
range = qq(2000,1):qq(2015,4);
d = struct();
d.x = hpf2(cumsum(tseries(range,@randn)));
d.y = hpf2(cumsum(tseries(range,@randn)));
d.z = hpf2(cumsum(tseries(range,@randn)));
d.a = hpf2(cumsum(tseries(range,@randn)));
d.b = hpf2(cumsum(tseries(range,@randn)));
This.TestData.range = range;
This.TestData.d = d;
end


%**************************************************************************


function testContributionsVAR(This)
range = This.TestData.range;
nPer = length(range);
d = This.TestData.d;
v = VAR({'x','y','z'});
[v,vd] = estimate(v,d,range,'order=',2);
s = simulate(v,vd,range(3:end));
c = simulate(v,vd,range(3:end),'contributions=',true);
assertEqual(This,double(sum(c.x,2)),double(s.x),'AbsTol',1e-14);
assertEqual(This,double(sum(c.y,2)),double(s.y),'AbsTol',1e-14);
assertEqual(This,double(sum(c.z,2)),double(s.z),'AbsTol',1e-14);
assertEqual(This,double(c.x{:,end}),zeros(nPer,1));
assertEqual(This,double(c.y{:,end}),zeros(nPer,1));
assertEqual(This,double(c.z{:,end}),zeros(nPer,1));
end % testContributionsVAR()


%**************************************************************************


function testContributionsVARX(This)
range = This.TestData.range;
d = This.TestData.d;
v = VAR({'x','y','z'}, ...
    'exogenous=',{'a','b'});
[v,vd] = estimate(v,d,range,'order=',2);
s = simulate(v,vd,range(3:end));
c = simulate(v,vd,range(3:end),'contributions=',true);
assertEqual(This,double(sum(c.x,2)),double(s.x),'AbsTol',1e-14);
assertEqual(This,double(sum(c.y,2)),double(s.y),'AbsTol',1e-14);
assertEqual(This,double(sum(c.z,2)),double(s.z),'AbsTol',1e-14);
end % testContributionsPVAR()


%**************************************************************************


function testContributionsPVAR(This)
range = This.TestData.range;
d = This.TestData.d;
D = struct();
D.A = d;
D.B = d;
v = VAR({'x','y','z'}, ...
    'exogenous=',{'a','b'}, ...
    'groups=',{'A','B'});
[v,vd] = estimate(v,D,range,'order=',2);
s = simulate(v,vd,range(3:end));
c = simulate(v,vd,range(3:end),'contributions=',true);
assertEqual(This,double(sum(c.A.x,2)),double(s.A.x),'AbsTol',1e-14);
assertEqual(This,double(sum(c.A.y,2)),double(s.A.y),'AbsTol',1e-14);
assertEqual(This,double(sum(c.A.z,2)),double(s.A.z),'AbsTol',1e-14);
assertEqual(This,double(sum(c.B.x,2)),double(s.B.x),'AbsTol',1e-14);
assertEqual(This,double(sum(c.B.y,2)),double(s.B.y),'AbsTol',1e-14);
assertEqual(This,double(sum(c.B.z,2)),double(s.B.z),'AbsTol',1e-14);
end % testContributionsPVAR()

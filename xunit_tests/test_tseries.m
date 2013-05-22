% test_tseries.m

function test_tseries
initTestSuite;
end

function test_sded(obj)
x=tseries();
assertEqual(startdate(x),NaN);
assertEqual(enddate(x),NaN);
end

function test_assign(obj) %#ok<*DEFNU>
x=tseries();
x(1:5)=2:6;
assertVectorsAlmostEqual(double(x),(2:6)');
assertVectorsAlmostEqual(range(x),1:5);
end

function test_acf(obj)
x=tseries(1:10,1:10);
assertElementsAlmostEqual(acf(x),var(x));
end
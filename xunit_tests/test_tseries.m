% test_tseries.m

function test_tseries
initTestSuite;
end

function x=setup()
x=tseries(qq(1,1):qq(3,2),sin(1:10));
end

function test_wrongFreqConcat(~)
a=tseries(dd(1,1,1),1);
b=tseries(qq(2,2),2);
assertExceptionThrown(@()[a,b],'IRIS:tseries:catcheck');
assertExceptionThrown(@()[a;b],'IRIS:tseries:catcheck');
end

function test_cat(~)
a=tseries(qq(1,1),1);
b=tseries(qq(1,1),2);
assertElementsAlmostEqual(double([a b]),[double(a) double(b)]);
b=tseries(qq(1,2),2);
assertElementsAlmostEqual(double([a;b]),[double(a);double(b)]);
end

function test_sded(~)
x=tseries();
assertEqual(startdate(x),NaN);
assertEqual(enddate(x),NaN);
end

function test_assign(~) %#ok<*DEFNU>
x=tseries();
x(1:5)=2:6;
assertVectorsAlmostEqual(double(x),(2:6)');
assertVectorsAlmostEqual(range(x),1:5);
end

function test_subsindex(obj)
assertVectorsAlmostEqual(obj(:),double(obj));
end

function test_detrend(obj)
expected=[0
   0.221770008206370
  -0.392463844370859
  -1.136442781550070
  -1.184620994716695
  -0.351168652063897
   0.739177011042403
   1.225492225135581
   0.802196029942541
  -0.000000000000001];
assertVectorsAlmostEqual(double(detrend(obj)),expected);
end

function test_isscalar(~)
assertEqual(isscalar(tseries(1,1)),true);
assertEqual(isscalar(tseries(1:2,1)),true);
assertEqual(isscalar(tseries(1,[1 2])),false);
end

function test_round(obj)
assertVectorsAlmostEqual(double(round(obj)),round(double(obj)));
end

function test_bxsfun(obj)
assertVectorsAlmostEqual(double(bsxfun(@max,obj,0)),bsxfun(@max,double(obj),0));
end

function test_acf(obj)
assertElementsAlmostEqual(acf(obj),var(obj));
end

function test_mean(obj)
assertElementsAlmostEqual(mean(obj),0.141118837121801);
end

function test_hpf(obj)
expected=[0.332158721583314
   0.287235347551190
   0.242630293683581
   0.199050668944550
   0.157140138369643
   0.116944958766749
   0.077813846685613
   0.038847793390374
  -0.000490226884807
  -0.040143170872499];
assertVectorsAlmostEqual(double(hpf(obj)),expected);
expected=[   0.509312263224583
   0.622062079274492
  -0.101510285623714
  -0.955853164252478
  -1.116064413032781
  -0.396360456965675
   0.579172752033176
   0.950510453233008
   0.412608712126564
  -0.503877940016871];
assertVectorsAlmostEqual(double(hpf2(obj)),expected);
end

function test_isempty(~)
assertEqual(isempty(tseries()),true);
assertEqual(isempty(tseries(1,1)),false);
end

function test_redate(obj)
assertVectorsAlmostEqual(qq(2,2):qq(4,3),range(redate(obj,qq(1,1),qq(2,2))));
end

function test_dates(obj)
assertEqual(char(dat2str(str2dat('01-2010','dateformat=','MM-YYYY','freq',12))),'2010M01');
assertEqual(char(dat2str(str2dat('01-2010','dateformat=','MM-YYYY','freq',4))),'2010Q1');
assertEqual(char(dat2str(str2dat('01-2010','dateformat=','MM-YYYY','freq',1))),'2010Y');
assertEqual(char(dat2str(qq(2010,1))),'2010Q1');
assertEqual(char(dat2str(mm(2010,1))),'2010M01');
end





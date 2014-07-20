if ismatlab
    rng(0);
else
    rand('seed',0);
end

actDbase = struct();
actDbase.x = tseries(ww(2000,1):ww(2010,'end'),@rand);
actDbase.x = round(100*actDbase.x,2);

dbsave(actDbase,'testSaveLoad1.csv');
expDbase = dbload('testSaveLoad1.csv');
myassert(actDbase.x(:), expDbase.x(:)) ;

dbsave(actDbase,'testSaveLoad2.csv',Inf, ...
    'dateFormat=','$YYYY-MM-DD');
expDbase = dbload('testSaveLoad2.csv', ...
    'dateFormat=','$YYYY-MM-DD','freq=',52);
myassert(actDbase.x(:), expDbase.x(:)) ;
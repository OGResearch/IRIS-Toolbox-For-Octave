function Tests = saveLoadTest()

Tests = functiontests(localfunctions) ;

end


%**************************************************************************
function testWeekly(This) %#ok<*DEFNU>

rng(0);

actDbase = struct();
actDbase.x = tseries(ww(2000,1):ww(2010,'end'),@rand);
actDbase.x = round(100*actDbase.x,2);

dbsave(actDbase,'testSaveLoad1.csv');
expDbase = dbload('testSaveLoad1.csv');
assertEqual(This, actDbase.x(:), expDbase.x(:)) ;

dbsave(actDbase,'testSaveLoad2.csv',Inf, ...
    'dateFormat=','$YYYY-MM-DD');
expDbase = dbload('testSaveLoad2.csv', ...
    'dateFormat=','$YYYY-MM-DD','freq=',52);
assertEqual(This, actDbase.x(:), expDbase.x(:)) ;

end % testMissingObs()

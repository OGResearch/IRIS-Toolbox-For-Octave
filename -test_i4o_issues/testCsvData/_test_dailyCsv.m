d = dbload('testDailyCsv.csv', ...
    'dateFormat=', '$M/D/YYYY', ...
    'freq=', 365) ;
actDbase = db2array(d, {'A', 'B', 'C', 'D'}) ;
actDbase(isnan(actDbase)) = 0 ;

if ismatlab
    expDbase = csvread('testDailyCsv.csv', 1, 1) ;
else
    expDbase = csvread('testDailyCsv.csv') ;
    expDbase = real(reshape(expDbase(6:end),4,[]))';
end

myassert(actDbase, expDbase) ;
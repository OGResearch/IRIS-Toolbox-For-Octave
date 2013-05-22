% xunitInit.m

function suite=xunitInit()
addpath(fullfile(irisroot,'xunit'));

suite = TestSuite.fromPwd();

% suite = TestSuite.fromName('model');

end
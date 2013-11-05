
thisFolder = fileparts(mfilename('fullpath')) ;

allTests = matlab.unittest.TestSuite.fromFolder(thisFolder, ...
    'includingSubfolders', true) ;

run(allTests)

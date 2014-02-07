
thisFolder = fileparts(mfilename('fullpath')) ;

allTests = matlab.unittest.TestSuite.fromFolder(thisFolder, ...
    'IncludingSubfolders', true) ;

run(allTests)

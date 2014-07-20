%% places
curFolder = pwd();
thisFolder = fileparts(mfilename('fullpath'));
addpath(thisFolder);

%% iris startup
cd([thisFolder filesep '..']);
irisstartup

%% run tests
subFolders = regexp(genpath(thisFolder),pathsep(),'split');
subFolders = subFolders(2:end);

errors = [];
testsCalledOverall = 0;
testsPassedOverall = 0;
for ix = 1:length(subFolders)
  if ~isempty(subFolders{ix})
    cd(subFolders{ix});
    fprintf('\n* tests from [%s]',subFolders{ix});
    testFiles = dir(fullfile(subFolders{ix},'test_*.m'));
    testsCalled = 0;
    testsPassed = 0;
    for jx = 1:length(testFiles)
      if ~testFiles(jx).isdir
        testsCalled = testsCalled + 1;
        fprintf('\n\t** %s\n',testFiles(jx).name);
        try
          err0 = [];
          err0 = runTest(testFiles(jx).name);
          if ~isempty(err0)
            rethrow(err0);
          end
          fprintf('\t-> Passed!\n');
          testsPassed = testsPassed + 1;
        catch err
          fprintf('\t-> Failed! See <errors> structure.\n');
          errors(end+1).test = testFiles(jx).name; %#ok<SAGROW>
          errors(end).except = err;
        end
      end
    end
    if testsCalled == 0
      fprintf('\n\n < No tests in this folder >\n\n');
    else
      fprintf('\n < Tests passed: %g. Tests failed: %g >\n\n',testsPassed,...
        testsCalled-testsPassed);
    end
    cd(curFolder);
    testsCalledOverall = testsCalledOverall + testsCalled;
    testsPassedOverall = testsPassedOverall + testsPassed;
  end
end

fprintf('\n\n -=[ %g of %g tests have succeeded in total ]=-\n',testsPassedOverall,...
  testsCalledOverall);
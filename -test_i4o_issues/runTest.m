function err0 = runTest(fileName)

err0 = [];

try
  run(fileName);
catch err0
  clear functions
end

end

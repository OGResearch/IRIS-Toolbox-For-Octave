function err0 = runTest(fileName)

err0 = [];

try
  eval(fileName(1:end-2));
catch err0
  clear functions
end

end

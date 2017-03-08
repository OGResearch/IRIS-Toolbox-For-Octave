function accessPersistVarFromNested

persistent myVar

disp(myVar);
myVar = randn;

myNested;

% Nested functions
% ----------------

  function myNested
    disp(myVar);
  end

end
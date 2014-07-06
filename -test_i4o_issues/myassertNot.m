function myassertNot(observ, expect, varargin)

try
  myassert(observ, expect, varargin);
catch
  return
end

error('Observed and expected were supposed to be not equal but in fact they are!');
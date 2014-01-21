try
  aa = clA;
  aa(end)
  clear aa
catch err
  clear aa
  if strncmp(err.message,'parse error near line 11',24)
    error('expected error:: ''end'' indexing operator cannot be overloaded when declared in classdef file');
  else
    rethrow(err);
  end
end

try
  aa = @clA;
  aa()
  clear aa
catch err
  clear aa
  if ~isempty(strfind(err.message,'max_recursion_depth exceeded'))
    error('expected error:: wrong processing of classdef method function_handle');
  else
    rethrow(err);
  end
end

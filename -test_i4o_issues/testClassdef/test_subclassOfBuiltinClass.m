try
  nn = subDouble;
catch err
  clear nn
  if ~isempty(strfind(err.message,'class not found: double'))
    error('expected error:: no possibility to make a subclass of a built-in class');
  else
    rethrow(err);
  end
end
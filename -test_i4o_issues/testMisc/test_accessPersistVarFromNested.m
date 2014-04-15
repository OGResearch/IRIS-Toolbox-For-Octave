try
  accessPersistVarFromNested;
catch err
  if ~isempty(strfind(err.message,'''myVar'' undefined'))
    error('expected error:: cannot access persistent variable from nested function');
  end
  rethrow(err);
end
try
  aa = @strfun.converteols;
  aa('test')
  clear aa
catch err
  clear aa
  if ~isempty(strfind(err.message,'function handle cannot be indexed with .'))
    error('expected error:: dot-syntax is not allowed when creating handles');
  else
    rethrow(err);
  end
end
cc = clA;

try
  cc.dataProt = 23;
  assert(cc.dataProt == 23);
  clear cc
catch err
  clear cc
  if ~isempty(strfind(err.message,'has protected access'))
    error('expected error:: protected property cannot be set from within a class method');
  else
    rethrow(err);
  end
  rethrow(err);
end

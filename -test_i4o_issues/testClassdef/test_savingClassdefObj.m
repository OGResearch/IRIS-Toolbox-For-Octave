try
  cc = clA;
  save('clAobj.mat','cc');
catch err
  clear cc
  if ~isempty(strfind(err.message,'map_value(): wrong type argument'))
    error('expected error:: failed to save an object of user-defined class');
  else
    rethrow(err);
  end
end
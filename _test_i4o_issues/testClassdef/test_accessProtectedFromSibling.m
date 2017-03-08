try
  c1 = tpkg2.chld1;
  c2 = tpkg2.chld2;
  c1.callerMeth(c2);
catch err
  clear c1 c2
  if ~isempty(strfind(err.message,'has protected access and cannot be run'))
    error('expected error:: sibling class method cannot be accessed even when common ancestor has homonymous method');
  else
    rethrow(err);
  end
end
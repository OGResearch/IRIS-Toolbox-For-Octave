ts1 = tseries(qq(1,1):qq(2,4),1:8);

try
  ts1(qq(2,2)) = 5555;
  assert(ts1(qq(2,2))==5555,'tseries::subsasgn works wrong, value was assigned incorrectly');
  clear ts1
catch err
  clear ts1
  if strncmp(err.message,'subsasgn: object cannot be index with',37)
    error('expected error:: subsasgn() method cannot be overloaded');
  else
    rethrow(err);
  end
  rethrow(err);
end

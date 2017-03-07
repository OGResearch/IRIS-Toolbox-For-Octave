absTol = eps()^(2/3);

x = tseries(qq(1,1):qq(3,2),sin(1:10)) ;
x(qq(1,3)) = NaN;

try
  myassert(mean(x), NaN, absTol) ;
  myassert(nanmean(x), 0.141118707017571, absTol) ;
catch err
  if ~isempty(strfind(err.message,'function handle cannot be indexed with .'))
    error('expected error:: dot-syntax is not allowed when creating handles');
  else
    rethrow(err);
  end
end

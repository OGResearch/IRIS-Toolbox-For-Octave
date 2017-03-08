toSolve = true;

try
  setup4tests;
catch err
  clear toSolve m mInit mInitSolved
  if ~isempty(strfind(err.message,'handles to nested functions are not yet supported'))
    error('expected error:: no possibility to solve non-linear models in iris4octave');
  else
    rethrow(err);
  end
end

m = mInit ;
mm = mInitSolved ;

myassert( issolved(model()), false) ;
myassert( issolved(m), false) ;
myassert( chksstate(m,'error=', false, 'warning=', false), false) ;
myassert( issolved(mm), true) ;
myassert( chksstate(mm,'error=', false, 'warning=', false), true) ;
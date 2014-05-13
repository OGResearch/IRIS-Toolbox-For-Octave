function myassert(observ, expect, varargin)

if ~ismatlab
  assert(observ, expect, varargin{:})
else
  if nargin > 2
    absTol = varargin{1};
  else
    absTol = 0;
  end
  if ischar(expect) || iscellstr(expect)
    assert(strcmp(observ, expect));
  elseif any(isnan(expect)) || any(isinf(expect))
    assert(isequaln(observ,expect));
  else
    absTol = absTol * ones(size(expect));
    assert(any(abs(observ-expect) <= absTol));
  end
end

function myassert(observ, expect, varargin)

if ~is.matlab
  assert(observ, expect, varargin{:})
else
  if nargin > 2
    absTol = varargin{1};
  else
    absTol = 0;
  end
  if ischar(expect) || iscellstr(expect)
    assert(strcmp(observ, expect));
  elseif isstruct(expect)
    fldsE = fieldnames(expect);
    fldsO = fieldnames(observ);
    inEonly = setdiff(expect,observ);
    if ~isempty(inEonly)
      error(['These fields are missing in Observed: ', ...
        repmat('%s,',1,length(inEonly)),'\b'],inEonly{:});
    end
    inOonly = setdiff(observ,expect);
    if ~isempty(inOonly)
      error(['These fields are missing in Expected: ', ...
        repmat('%s,',1,length(inOonly)),'\b'],inOonly{:});
    end
    for ix = 1 : length(fldsE)
      myassert(observ.(fldsE{ix}),expect.(fldsE{ix}),absTol);
    end
  elseif any(isnan(expect)) || any(isinf(expect))
    assert(isequaln(observ,expect));
  else
    absTol = absTol * ones(size(expect));
    assert(any(abs(observ-expect) <= absTol));
  end
end

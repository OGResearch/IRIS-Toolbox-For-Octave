function x = bb2zz(x,range,varargin)
warning('iris:obsolete','BB2ZZ is an obsolete function name. Use CONVERT instead.');
if nargin < 2
  range = Inf;
end
x = convert(x,2,range,varargin{:});
end
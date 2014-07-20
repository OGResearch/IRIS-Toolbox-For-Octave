function x = zz2yy(x,range,varargin)
warning('iris:obsolete','ZZ2YY is an obsolete function name. Use CONVERT instead.');
if nargin < 2
  range = Inf;
end
x = convert(x,1,range,varargin{:});
end
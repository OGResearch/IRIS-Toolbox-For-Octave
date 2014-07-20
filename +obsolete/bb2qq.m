function x = bb2qq(x,range,varargin)
warning('iris:obsolete','BB2QQ is an obsolete function name. Use CONVERT instead.');
if nargin < 2
  range = Inf;
end
x = convert(x,4,range,varargin{:});
end
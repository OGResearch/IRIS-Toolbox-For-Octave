function x = mm2bb(x,range,varargin)
warning('iris:obsolete','MM2BB is an obsolete function name. Use CONVERT instead.');
if nargin < 2
  range = Inf;
end
x = convert(x,6,range,varargin{:});
end
function varargout = dkfilter(varargin)

warning('iris:obsolete','DKFILTER is an obsolete function name. Use KFILTER instead.');
[varargout{1:nargout}] = kfilter(varargin{1:nargin});

end
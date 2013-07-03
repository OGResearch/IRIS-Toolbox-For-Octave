function varargout = acgf(varargin)
warning('iris:obsolete','ACGF is an obsolete function name. Use ACF instead.');
[varargout{1:nargout}] = acf(varargin{:});
end
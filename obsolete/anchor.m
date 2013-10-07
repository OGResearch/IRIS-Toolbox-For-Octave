function varargout = anchor(varargin)

warning('iris:obsolete','ANCHOR is an obsolete function name. Use EXOGENIZE instead.');
[varargout{1:nargout}] = exogenize(varargin{:});

end
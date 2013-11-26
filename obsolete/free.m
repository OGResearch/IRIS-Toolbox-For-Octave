function varargout = free(varargin)

warning('iris:obsolete','FREE is an obsolete function name. Use ENDOGENIZE instead.');
[varargout{1:nargout}] = endogenize(varargin{:});

end
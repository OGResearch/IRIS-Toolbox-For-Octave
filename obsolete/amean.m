function varargout = amean(varargin)

warning('iris:obsolete','AMEAN is an obsolete function name. Use MEAN instead.');
[varargout{1:nargout}] = mean(varargin{:});

end
function varargout = par(varargin)

warning('iris:obsolete','PAR is an obsolete function name. Use PARAGRAPH instead.');
[varargout{1:nargout}] = paragraph(varargin{:});

end
function varargout = approx(varargin)

warning('iris:obsolete','APPROX is an obsolete function name. Use SOLVE instead.\n');
[varargout{1:nargout}] = solve(varargin{:});

end
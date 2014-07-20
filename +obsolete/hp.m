function varargout = hp(varargin)

warning('iris:obsolete','HP is an obsolete function name. Use HPF instead.');
[varargout{1:nargout}] = hpf(varargin{:});

end
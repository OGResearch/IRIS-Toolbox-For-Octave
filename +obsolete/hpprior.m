function varargout = hpprior(varargin)

warning('iris:obsolete','HPPRIOR is an obsolete function name. Use HPF instead.');
[varargout{1:nargout}] = hpf(varargin{:});

end
function varargout = hwbpf(varargin)
warning('iris:obsolete','HWBPF is an obsolete function name. Use HWFSF instead.');
[varargout{1:nargout}] = hwfsf(varargin{:});
end
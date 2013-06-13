function varargout = loghpf(varargin)

[varargout{1:nargout}] = hpf(100*log(varargin{1}),varargin{2:nargin});
for i = 1 : nargout
  varargout{i} = exp(varargout{i}/100);
end

end
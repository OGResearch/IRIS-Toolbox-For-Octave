function [gap,tnd] = loghpgap(varargin)

[tnd,gap] = hpf(log(varargin{1}),varargin{2:nargin});
gap = exp(gap);
if nargout > 1, tnd = exp(tnd); end

end
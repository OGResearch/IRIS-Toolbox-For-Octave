function varargout = pcprior(varargin)

warning('iris:obsolete','PCPRIOR is an obsolete function name. Use LLFPRIOR instead.');
[xTnd,xGap] = llfprior(varargin{1:end});
if nargout < 2
  varargout{1} = xTnd;
else
  [varargout{1:2}] = deal(xTnd,xGap);
end

end
function varargout = pc(varargin)

warning('iris:obsolete','PC is an obsolete function name. Use LLF instead.');
[xTnd,xGap] = llf(varargin{1:end});
if nargout < 2
  varargout{1} = xTnd;
else
  [varargout{1:2}] = deal(xTnd,xGap);
end

end  
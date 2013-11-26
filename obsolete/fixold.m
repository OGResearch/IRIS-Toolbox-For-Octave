function varargout = fixold(varargin)

% function body ---------------------------------------------------------------------------------------------

for i = 1 : nargin
  varargout{i} = varargin{i};
  for j = fieldnames(varargout{i}).'
    if istseries(varargout{i}.(j{1})), varargout{i}.(j{1}) = fixold(varargout{i}.(j{1})); end
  end
end

end % of primary function -----------------------------------------------------------------------------------
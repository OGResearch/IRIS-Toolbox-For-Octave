function p = disclose(p,varargin)
warning('iris:obsolete','DISCLOSE is an obsolete function name. Use ENDOGENISE instead.');
p = endogenise(p,varargin{:});
end
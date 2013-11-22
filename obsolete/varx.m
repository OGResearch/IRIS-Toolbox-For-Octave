function v = varx(varargin)

warning('iris:obsolete','VARX is an obsolete function name. Use RVAR instead.');
v = rvar(varargin{1:end});

return
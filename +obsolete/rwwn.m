function [tnd,gap] = rwwn(varargin)

warning('iris:obsolete','RWWN is an obsolete function. Use LLF instead.');
[tnd,gap] = llf(varargin{:});

end
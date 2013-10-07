function [tnd,gap] = rwwnprior(varargin)

warning('iris:obsolete','RWWNPRIOR is an obsolete function. Use LLF instead.');
[tnd,gap] = llf(varargin{:});

end
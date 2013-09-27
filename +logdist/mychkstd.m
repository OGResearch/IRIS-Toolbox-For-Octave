function C = mychkstd(C)
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

if not( norm(triu(C)-C) < eps )
    % Compute square root matrix using Cholesky
    C = chol(C) ;
end
end

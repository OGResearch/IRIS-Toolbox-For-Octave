function EigVal = eig(This)
% eig  Eigenvalues of a VAR process.
%
% Syntax
% =======
%
%     E = eig(V)
%
% Input arguments
% ================
%
% * `V` [ VAR ] - VAR object whose eigenvalues will be returned.
%
% Output arguments
% =================
%
% * `E` [ numeric ] - VAR eigenvalues.
%
% Description
% ============
%
% This function is equivalent to calling
%
%     e = get(v,'eig')
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

EigVal = This.eigval;

end
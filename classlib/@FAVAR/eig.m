function e = eig(a)
% eig  Eigenvalues of the factor dynamic system.
%
% Syntax
% =======
%
%     e = eig(a)
%
% Input arguments
% ================
%
% * `a` [ FAVAR ] - FAVAR object.
%
% Output arguments
% =================
%
% * `e` [ numeric ] - Eigenvalues associated with the factor system.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%**************************************************************************

e = a.eigval;

end
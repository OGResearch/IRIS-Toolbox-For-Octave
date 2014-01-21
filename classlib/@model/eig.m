function eigval = eig(this,alt)
% eig  Eigenvalues of the model transition matrix.
%
% Syntax
% =======
%
%     e = eig(m)
%
% Input arguments
% ================
%
% * `m` [ model ] - Model object whose eigenvalues will be returned.
%
% Output arguments
% =================
%
% * `e` [ numeric ] - Array of all eigenvalues associated with the model,
% i.e. all stable, unit, and unstable roots are included.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

if nargin < 2 || isequal(alt,Inf)
    alt = 1 : size(this.Assign,3);
else
    alt = alt(:)';
end

%**************************************************************************

eigval = this.eigval(1,:,alt);

end

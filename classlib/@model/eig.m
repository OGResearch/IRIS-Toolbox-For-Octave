function E = eig(This,Alt)
% eig  Eigenvalues of the transition matrix.
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
% -Copyright (c) 2007-2014 IRIS Solutions Team.

try
    Alt; %#ok<VUNUS>
catch
    Alt = Inf;
end

if isequal(Alt,Inf)
    Alt = ':';
end

%--------------------------------------------------------------------------

E = This.eigval(1,:,Alt);

end

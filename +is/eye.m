function Flag = eye(X,Tol)
% eye  True if variable is an identity matrix.
%
% Syntax 
% =======
%
%     Flag = is.eye(X)
%
% Input arguments
% ================
%
% * `X` [ numeric ] - Variable that will be tested.
%
% Output arguments
%
% * `Flag` [ `true` | `false` ] - True if the input variable `X` is an
% identity matrix.
%
% Description
% ============
%
% Example
% ========
%
%     X1 = rand(5);
%     is.eye(X1)
%     ans =
%          0
%
%     X2 = eye(3);
%     is.eye(X2)
%     ans =
%          1
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

if nargin < 2
  Tol = getrealsmall();
end

Flag = isnumeric(X) && ndims(X) == 2 ...
    && all(all(abs(X - eye(size(X))) <= Tol)); %#ok<ISMAT>

end
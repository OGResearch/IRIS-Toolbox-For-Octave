function Flag = numericscalar(X)
% numericscalar  True if variable is a numeric scalar.
%
% Syntax 
% =======
%
%     Flag = is.numericscalar(X)
%
% Input arguments
% ================
%
% * `X` [ numeric ] - Variable that will be tested.
%
% Output arguments
%
% * `Flag` [ `true` | `false` ] - True if the input variable `X` is a
% logical scalar.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

Flag = isnumeric(X) && numel(X) == 1;

end
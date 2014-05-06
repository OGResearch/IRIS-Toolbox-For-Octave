function Flag = intscalar(X)
% numericscalar  True if variable is an integer scalar (of any numeric type).
%
% Syntax 
% =======
%
%     Flag = is.intscalar(X)
%
% Input arguments
% ================
%
% * `X` [ numeric ] - Variable that will be tested.
%
% Output arguments
%
% * `Flag` [ `true` | `false` ] - True if the input variable `X` is an
% integer scalar of any numeric type.
%
% Description
% ============
%
% Example
% ========
%
%     X = 12;
%     Y = pi;
%     Z = int8(1);
%     is.intscalar(X)
%     ans =
%          1
%     is.intscalar(Y)
%     ans =
%          0
%     is.intscalar(Z)
%     ans =
%          1
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

Flag = isnumeric(X) && numel(X) == 1 && round(X) == X;

end
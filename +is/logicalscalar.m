function Flag = logicalscalar(X)
% logicalscalar  True if variable is a logical scalar.
%
% Syntax 
% =======
%
%     Flag = is.logicalscalar(X)
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

Flag = islogical(X) && numel(X) == 1;

end
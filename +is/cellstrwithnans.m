function Flag = cellstrwithnans(X)
% func  True if variable is a cell array of strings or NaNs.
%
% Syntax 
% =======
%
%     Flag = is.cellstrwithnans(X)
%
% Input arguments
% ================
%
% * `X` [ numeric ] - Variable that will be tested.
%
% Output arguments
%
% * `Flag` [ `true` | `false` ] - True if the input variable `X` is a cell
% array of strings or `NaN`s.
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

Flag = all(cellfun(@(x) ischar(x) || isequalwithequalnans(x,NaN),X(:)));

end
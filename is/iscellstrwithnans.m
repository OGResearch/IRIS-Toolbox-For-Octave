function Flag = iscellstrwithnans(X)
% iscellstrwithnans  True if variable is cell array of strings or NaNs.
%
% Syntax 
% =======
%
%     Flag = iscellstrwithnans(X)
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

try
    Flag = all(cellfun(@(x) ischar(x) || isequaln(x,NaN),X(:)));
catch
    Flag = all(cellfun(@(x) ischar(x) || isequalwithequalnans(x,NaN),X(:))); %#ok<DISEQN>
end

end

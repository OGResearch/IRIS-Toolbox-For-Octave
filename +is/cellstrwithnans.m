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

try
    isequaln(0,0);
    isequalnFunc = @isequaln;
catch
    isequalnFunc = @isequalwithequalnans;
end

Flag = all(cellfun(@(x) ischar(x) || isequalnFunc(x,NaN),X(:)));

end
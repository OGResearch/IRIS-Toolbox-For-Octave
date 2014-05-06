function Flag = cellfunc(X)
% func  True if variable is a cell array of function handles.
%
% Syntax 
% =======
%
%     Flag = is.cellfunc(X)
%
% Input arguments
% ================
%
% * `X` [ numeric ] - Variable that will be tested.
%
% Output arguments
%
% * `Flag` [ `true` | `false` ] - True if the input variable `X` is a cell
% array of function handles.
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

Flag = iscell(X) && all(cellfun(@(x) isa(x,'function_handle'),X(:)));

end
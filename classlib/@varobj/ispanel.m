function Flag = ispanel(This)
% ispanel  True for panel VAR based objects.
%
% Syntax
% =======
%
%     Flag = ispanel(X)
%
% Input arguments
% ================
%
% * `X` [ VAR | SVAR | FAVAR ]  - VAR based object.
%
% Output arguments
% =================
%
% * `Flag` [ `true` | `false` ] - True if the VAR based object, `X`, is
% based on a panel of data.
%
% Description
% ============
%
% Plain, i.e. non-panel, VAR based objects are created by calling the
% constructor with one input argument: the list of variables. Panel VAR
% based objects are created by calling the constructor with two input
% arguments: the list of variables, and the names of groups of data.
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------
 
Flag = ~isempty(This.GroupNames);

end
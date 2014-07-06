function Flag = FAVAR(X)
% FAVAR  True if variable is a model object.
%
% Syntax 
% =======
%
%     Flag = is.FAVAR(X)
%
% Input arguments
% ================
%
% * `X` [ numeric ] - Variable that will be tested.
%
% Output arguments
%
% * `Flag` [ `true` | `false` ] - True if the input variable `X` is a FAVAR
% object.
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

Flag = isa(X,'FAVAR');

end
function Flag = issvarobj(X)
% isVAR  True if variable is svarobj object.
%
% Syntax 
% =======
%
%     Flag = issvarobj(X)
%
% Input arguments
% ================
%
% * `X` [ object ] - Variable that will be tested.
%
% Output arguments
%
% * `Flag` [ `true` | `false` ] - True if the input variable `X` is a VAR
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

if false % ##### MOSW
    Flag = isa(X,'svarobj');
else
    Flag = isa(X,'SVAR') || isa(X,'svarobj'); %#ok<UNRCH>
end

end

function Flag = isvarobj(X)
% isVAR  True if variable is varobj object.
%
% Syntax 
% =======
%
%     Flag = isvarobj(X)
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
    Flag = isa(X,'varobj');
else
    Flag = isa(X,'varobj') || isVAR(X) || isFAVAR(X); %#ok<UNRCH>
end

end

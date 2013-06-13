function N = length(This)
% length  Number or priors imposed in system priors object.
%
% Syntax
% =======
%
%     N = length(S)
%
% Input arguments
% ================
%
% * `S` [ systempriors ] - System priors,
% [`systempriors`](systempriors/Contents) object.
%
% Output arguments
% =================
%
% * `N` [ numeric ] - Number of priors imposed in the system priors object,
% `S`.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

N = length(This.eval);

end
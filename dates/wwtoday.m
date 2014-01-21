function Dat = wwtoday()
% wwtoday  IRIS serial date number for current week.
%
% Syntax
% =======
%
%     Dat = wwtoday()
%
% Output arguments
% =================
%
% * `Dat` [ numeric ]  - IRIS serial date number for current week.
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

today = floor(now());
Dat = day2ww(today);

end

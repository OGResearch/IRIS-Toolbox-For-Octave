function Dat = qqtoday()
% qqtoday  IRIS serial date number for current quarter.
%
% Syntax
% =======
%
%     Dat = qqtoday()
%
% Output arguments
% =================
%
% * `Dat` [ numeric ]  - IRIS serial date number for current quarter.
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

[year,month] = datevec(now());
Dat = qq(year,1+floor((month-1)/3));

end

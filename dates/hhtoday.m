function Dat = hhtoday()
% hhtoday  IRIS serial date number for current half-year.
%
% Syntax
% =======
%
%     Dat = hhtoday()
%
% Output arguments
% =================
%
% * `Dat` [ numeric ] - IRIS serial date number for current half-year.
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

[year,month] = datevec(now());
Dat = zz(year,1+floor((month-1)/6));

end
function Dat = mmtoday()
% mmtoday  IRIS serial date number for current month.
%
% Syntax
% =======
%
%     Dat = mmtoday()
%
% Output arguments
% =================
%
% * `Dat` [ numeric ]  - IRIS serial date number for current month.
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
Dat = mm(year,month);

end
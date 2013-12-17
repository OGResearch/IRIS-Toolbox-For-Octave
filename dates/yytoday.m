function Dat = yytoday()
% yytoday  IRIS serial date number for current year.
%
% Syntax
% =======
%
%     Dat = yytoday()
%
% Output arguments
% =================
%
% * `Dat` [ numeric ]  - IRIS serial date number for current year.
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

[year,~] = datevec(now());
Dat = yy(year);

end
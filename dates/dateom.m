function D = dateom(D)
% dateom  End of month for the specified daily date.
%
% Syntax
% =======
%
%     Eom = dateom(D)
%
% Input arguments
% ================
%
% * `D` [ numeric ] - Daily serial date number.
%
% Output arguments
% =================
%
% * `Eom` [ numeric ] - Daily serial date number for the last day of the
% same month as `D`.
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

[y,m] = datevec(D);
D = datenum([y,m,eomday(y,m)]);

end
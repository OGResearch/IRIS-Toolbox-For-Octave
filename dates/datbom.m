function D = datbom(D)
% datbom  Beginning of month for the specified daily date.
%
% Syntax
% =======
%
%     Bom = datebom(D)
%
% Input arguments
% ================
%
% * `D` [ numeric ] - Daily serial date number.
%
% Output arguments
% =================
%
% * `Bom` [ numeric ] - Daily serial date number for the first day of the
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
D = datenum([y,m,1]);

end
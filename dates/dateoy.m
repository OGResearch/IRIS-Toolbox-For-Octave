function D = dateoy(D)
% dateoy  End of year for the specified daily date.
%
% Syntax
% =======
%
%     Eoy = dateoy(D)
%
% Input arguments
% ================
%
% * `D` [ numeric ] - Daily serial date number.
%
% Output arguments
% =================
%
% * `Eoy` [ numeric ] - Daily serial date number for the last day of the
% same year as `D`.
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

[y,m] = datevec(D); %#ok<NASGU>
D = datenum([y,12,eomday(y,12)]);

end
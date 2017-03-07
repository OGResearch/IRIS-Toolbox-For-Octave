function D = datboy(D)
% datboy  Beginning of year for the specified daily date.
%
% Syntax
% =======
%
%     Boy = dateboy(D)
%
% Input arguments
% ================
%
% * `D` [ numeric ] - Daily serial date number.
%
% Output arguments
% =================
%
% * `Boy` [ numeric ] - Daily serial date number for the first day of the
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
D = datenum([y,1,1]);

end
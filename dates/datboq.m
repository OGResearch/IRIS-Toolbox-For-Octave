function D = datboq(D)
% datboq  Beginning of quarter for the specified daily date.
%
% Syntax
% =======
%
%     Boq = datboq(D)
%
% Input arguments
% ================
%
% * `D` [ numeric ] - Daily serial date number.
%
% Output arguments
% =================
%
% * `Boq` [ numeric ] - Daily serial date number for the first day of the
% same quarter as `D`.
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

[y,m] = datevec(D);
m = 3*(ceil(m/3)-1) + 1;
D = datenum([y,m,1]);

end
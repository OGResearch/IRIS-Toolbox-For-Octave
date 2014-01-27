function D = dateoq(D)
% dateoq  End of quarter for the specified daily date.
%
% Syntax
% =======
%
%     Eoq = dateoq(D)
%
% Input arguments
% ================
%
% * `D` [ numeric ] - Daily serial date number.
%
% Output arguments
% =================
%
% * `Eoq` [ numeric ] - Daily serial date number for the last day of the
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
m = 3*(ceil(m/3)-1) + 3;
D = datenum([y,m,eomday(y,m)]);

end
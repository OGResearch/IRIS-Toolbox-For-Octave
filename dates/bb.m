function dat = bb(varargin)
% bb  IRIS serial date numbers for dates with bi-monthly frequency.
%
% Syntax
% =======
%
%     d = bb(y)
%     d = bb(y,b)
%
% Input arguments
% ================
%
% * `y` [ numeric ] - Years.
%
% * `q` [ numeric ] - B-months; if missing, first bi-month is assumed.
%
% Output arguments
% =================
%
% * `d` [ numeric ] - IRIS serial date numbers representing the input
% bi-months.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%**************************************************************************

dat = datcode(6,varargin{:});

end

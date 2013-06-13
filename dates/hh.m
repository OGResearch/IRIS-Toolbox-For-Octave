function dat = hh(varargin)
% hh  IRIS serial date numbers for dates with half-yearly frequency.
%
% Syntax
% =======
%
%     d = hh(y)
%     d = hh(y,h)
%
% Input arguments
% ================
%
% * `y` [ numeric ] - Years.
%
% * `h` [ numeric ] - Half-years; if missing, first half-year is used.
%
% Output arguments
% =================
%
% * `d` [ numeric ] - IRIS serial date numbers representing the input
% half-years.
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

dat = datcode(2,varargin{:});

end

function dat = zz(varargin)
% zz  IRIS serial date numbers for dates with half-yearly frequency.
%
% Syntax
% =======
%
%     d = zz(y)
%     d = zz(y,z)
%
% Output arguments
% =================
%
% * `d` [ numeric ] - IRIS serial date numbers.
%
% Input arguments
% ================
%
% * `y` [ numeric ] - Years.
%
% * `z` [ numeric ] - Half-years; if missing, first half-year is assumed.
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

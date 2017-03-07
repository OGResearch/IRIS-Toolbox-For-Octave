function y = double(x)
% double  Return tseries observations as double-precision numeric array.
%
% Syntax
% =======
%
%     y = double(x)
%
% Input arguments
% ================
%
% * `x` [ tseries ] - Tseries object whose observations will be returned as
% double-precision numeric array.
%
% Output arguments
% =================
%
% * `y` [ numeric ] - Double-precision numeric array with the input tseries
% observations in columns.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%**************************************************************************

y = double(x.data);

end
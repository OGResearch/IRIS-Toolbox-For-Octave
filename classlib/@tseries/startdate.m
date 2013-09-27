function y = startdate(x)
% startdate  Date of the first available observation in a tseries object.
%
% Syntax
% =======
%
%     d = startdate(x)
%
% Input arguments
% ================
%
% * `x` [ tseries ] - Tseries object.
%
% Output arguments
% =================
%
% * `d` [ numeric ] - IRIS serial date number representing the date of the
% first observation available in the input tseries.
%
% Description
% ============
%
% The `startdate` function is equivalent to calling
%
%     get(x,'startDate')
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%**************************************************************************

y = x.start;

end

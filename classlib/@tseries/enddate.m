function y = enddate(x)
% enddate  Date of the last available observation in a tseries object.
%
% Syntax
% =======
%
%     d = enddate(x)
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
% last observation available in the input tseries.
%
% Description
% ============
%
% The `startdate` function is equivalent to calling
%
%     get(x,'endDate')
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%**************************************************************************

y = x.start + size(x.data,1) - 1;

end
function Y = startdate(X)
% startdate  Date of the first available observation in a tseries object.
%
% Syntax
% =======
%
%     D = startdate(X)
%
% Input arguments
% ================
%
% * `X` [ tseries ] - Tseries object.
%
% Output arguments
% =================
%
% * `D` [ numeric ] - IRIS serial date number representing the date of the
% first observation available in the input tseries.
%
% Description
% ============
%
% The `startdate` function is equivalent to calling
%
%     get(X,'startDate')
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

Y = X.start;

end

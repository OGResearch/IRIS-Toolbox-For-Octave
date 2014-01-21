function D = enddate(X)
% enddate  Date of the last available observation in a tseries object.
%
% Syntax
% =======
%
%     D = enddate(X)
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

%--------------------------------------------------------------------------

D = X.start + size(X.data,1) - 1;

end
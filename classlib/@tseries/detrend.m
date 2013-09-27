function This = detrend(This,varargin)
% detrend  Remove a linear time trend.
%
% Syntax
% =======
%
%     X = detrend(X)
%     X = detrend(X,Range)
%
% Input arguments
% ================
%
% * `X` [ tseries ] - Input time series.
%
% * `Range` [ numeric | `Inf` ] - The date range on which the trend will be
% computed; `Inf` means the entire range available will be used.
%
% Output arguments
% =================
%
% * `x` [ tseries ] - Output time series with a trend removed.
%
% Options
% ========
%
% See [`tseries/trend`](tseries/trend) for options available.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

This = This - trend(This,varargin{:});

end
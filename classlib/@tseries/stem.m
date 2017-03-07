function varargout = stem(varargin)
% stem  Plot tseries as discrete sequence data.
%
% Syntax
% =======
%
%     [h,range] = stem(x,...)
%     [h,range] = stem(range,x,...)
%     [h,range] = stem(a,range,x,...)
%
% Input arguments
% ================
%
% * `Ax` [ handle | numeric ] - Handle to axes in which the graph will be
% plotted; if not specified, the current axes will used.
%
% * `Range` [ numeric ] - Date range; if not specified the entire range of
% the input tseries object will be plotted.
%
% * `X` [ tseries ] - Input tseries object whose columns will be ploted as
% a stem graph.
%
% Output arguments
% =================
%
% * `H` [ handle | numeric ] - Handles to stems plotted.
%
% * `Range` [ numeric ] - Actually plotted date range.
%
% Options
% ========
%
% See help on [`tseries/plot`](tseries/plot) and the built-in function
% `stem` for all options available.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

% AREA, BAR, PLOT, CONBAR, PLOTCMP, PLOTYY, STEM

%--------------------------------------------------------------------------

[varargout{1:nargout}] = tseries.myplot(@stem,varargin{:});

end
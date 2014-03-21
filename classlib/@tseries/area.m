function varargout = area(varargin)
% area  Area graph for tseries objects.
%
% Syntax
% =======
%
%     [H,Range] = area(X,...)
%     [H,Range] = area(Range,X,...)
%     [H,Range] = area(Ax,Range,X,...)
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
% an area graph.
%
% Output arguments
% =================
%
% * `H` [ handle | numeric ] - Handles to areas plotted.
%
% * `Range` [ numeric ] - Actually plotted date range.
%
% Options
% ========
%
% * `'dateFormat='` [ char | *`irisget('plotDateFormat')`* ] - Date format
% for the tick marks on the x-axis.
%
% * `'dateTick='` [ numeric | *`Inf`* ] - Vector of dates locating tick
% marks on the x-axis; Inf means they will be created automatically.
%
% * `'tight='` [ `true` | *`false`* ] - Make the y-axis tight.
%
% See help on built-in `area` function for other options available.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

% AREA, BAR, PLOT, CONBAR, PLOTYY, STEM

%--------------------------------------------------------------------------

[varargout{1:nargout}] = tseries.myplot(@area,varargin{:});

end

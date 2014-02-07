function varargout = bar(varargin)
% bar  Bar graph for tseries objects.
%
% Syntax
% =======
%
%     [h,range] = bar(x,...)
%     [h,range] = bar(range,x,...)
%     [h,range] = bar(a,range,x,...)
%
% Input arguments
% ================
%
% * `a` [ numeric ] - Handle to axes in which the graph will be plotted; if
% not specified, the current axes will used.
%
% * `range` [ numeric ] - Date range; if not specified the entire range of
% the input tseries object will be plotted.
%
% * `x` [ tseries ] - Input tseries object whose columns will be ploted as
% a bar graph.
%
% Output arguments
% =================
%
% * `h` [ numeric ] - Handles to the bars plotted.
%
% * `range` [ numeric ] - Actually plotted date range.
%
% Options
% ========
%
% * `'dateformat='` [ char | *irisget('plotdateformat')* ] - Date format for
% the tick marks on the x-axis.
%
% * `'datetick='` [ numeric | *`Inf`* ] - Vector of dates locating tick marks
% on the x-axis; Inf means they will be created automatically.
%
% * `'tight='` [ `true` | *`false`* ] - Make the y-axis tight.
%
% See help on built-in `bar` function for other options available.
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

%**************************************************************************

[varargout{1:nargout}] = tseries.myplot(@bar,varargin{:});

end
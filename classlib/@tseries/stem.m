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
% * `a` [ numeric ] - Handle to axes in which the graph will be plotted; if
% not specified, the current axes will used.
%
% * `range` [ numeric ] - Date range; if not specified the entire range of
% the input tseries object will be plotted.
%
% * `x` [ tseries ] - Input tseries object whose columns will be ploted as
% a stem graph.
%
% Output arguments
% =================
%
% * `h` [ numeric ] - Vector of handles to the stems plotted.
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
% See help on built-in `stem` function for other options available.
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

%**************************************************************************

[varargout{1:nargout}] = tseries.myplot(@stem,varargin{:});

end
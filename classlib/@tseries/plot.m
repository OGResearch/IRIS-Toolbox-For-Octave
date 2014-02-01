function varargout = plot(varargin)
% plot  Line graph for tseries objects.
%
% Syntax
% =======
%
%     [h,range] = plot(x,...)
%     [h,range] = plot(range,x,...)
%     [h,range] = plot(a,range,x,...)
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
% a line graph.
%
% Output arguments
% =================
%
% * `h` [ numeric ] - Handles to the lines plotted.
%
% * `range` [ numeric ] - Actually plotted date range.
%
% Options
% ========
%
% * `'dateFormat='` [ char | *irisget('plotdateformat')* ] - Date format for
% the tick marks on the x-axis.
%
% * `'datePosition='` [ *'centre'* | 'end' | 'start' ] - Position of each
% date point within a given period span.
%
% * `'datetick='` [ numeric | *`Inf`* ] - Vector of dates locating tick marks
% on the x-axis; Inf means they will be created automatically.
%
% * `'tight='` [ `true` | *`false`* ] - Make the y-axis tight.
%
% See help on built-in `plot` function for other options available.
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

% TODO: Add help on date format related options.

% TODO: Document the use of half-ranges in plot functions [-Inf,date],
% [date,Inf].

%**************************************************************************

[varargout{1:nargout}] = tseries.myplot(@plot,varargin{:});

end

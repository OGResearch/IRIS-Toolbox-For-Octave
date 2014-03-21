function varargout = plot(varargin)
% plot  Line graph for tseries objects.
%
% Syntax
% =======
%
%     [H,Range] = plot(X,...)
%     [H,Range] = plot(Range,X,...)
%     [H,Range] = plot(Ax,Range,X,...)
%
% Input arguments
% ================
%
% * `Ax` [ numeric ] - Handle to axes in which the graph will be plotted;
% if not specified, the current axes will used.
%
% * `Range` [ numeric ] - Date range; if not specified the entire range of
% the input tseries object will be plotted.
%
% * `X` [ tseries ] - Input tseries object whose columns will be ploted as
% a line graph.
%
% Output arguments
% =================
%
% * `H` [ numeric ] - Handles to lines plotted.
%
% * `Range` [ numeric ] - Actually plotted date range.
%
% Options
% ========
%
% * `'dateFormat='` [ char | *`irisget('plotdateformat')`* ] - Date format
% for the tick marks on the X-axis.
%
% * `'datePosition='` [ *`'centre'`* | `'end'` | `'start'` ] - Position of
% each date point within a given period span.
%
% * `'dateTick='` [ numeric | *`Inf`* ] - Vector of dates locating tick
% marks on the X-axis; Inf means they will be created automatically.
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

%--------------------------------------------------------------------------

[varargout{1:nargout}] = tseries.myplot(@plot,varargin{:});

end

function varargout = scatter(varargin)
% scatter  Scatter graph for tseries objects.
%
% Syntax
% =======
%
%     [H,Range] = scatter([X,Y],...)
%     [H,Range] = scatter(Range,[X,Y],...)
%     [H,Range] = scatter(Ax,Range,[X,Y],...)
%
% Input arguments
% ================
%
% * `ax` [ numeric ] - Handle to axes in which the graph will be plotted; if
% not specified, the current axes will used.
%
% * `Range` [ numeric ] - Date range; if not specified the entire range of
% the input tseries object will be plotted.
%
% * `X`, `Y` [ tseries ] - Two scalar tseries objects plotted on the x-axis
% and the y-axis, respectively.
%
% Output arguments
% =================
%
% * `H` [ numeric ] - Handles to the lines plotted.
%
% * `Range` [ numeric ] - Actually plotted date range.
%
% Options
% ========
%
% See help on [`tseries/plot`](tseries/plot) and the built-in function
% `scatter` for all options available.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

% AREA, BAR, PLOT, CONBAR, PLOTCMP, PLOTYY, STEM, SCATTER

% TODO: Add help on date format related options.

%--------------------------------------------------------------------------

[varargout{1:nargout}] = tseries.myplot(@scatter,varargin{:});

end

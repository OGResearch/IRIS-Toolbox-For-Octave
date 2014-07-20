function varargout = bar(varargin)
% bar  Bar graph for tseries objects.
%
% Syntax
% =======
%
%     [H,Range] = bar(X,...)
%     [H,Range] = bar(Range,X,...)
%     [H,Range] = bar(Ax,Range,X,...)
%
% Input arguments
% ================
%
% * `Ax` [ handle | numeric ] - Handle to axes in which the graph will be
% plotted; if not specified, the current axes will used.
%
% * `Range` [ numeric ] - Date Range; if not specified the entire Range of
% the input tseries object will be plotted.
%
% * `X` [ tseries ] - Input tseries object whose columns will be ploted as
% a bar graph.
%
% Output arguments
% =================
%
% * `H` [ handle | numeric ] - Handles to bars plotted.
%
% * `Range` [ numeric ] - Actually plotted date Range.
%
% Options
% ========
%
% See help on [`tseries/bar`](tseries/bar) and the built-in function `bar`
% for all options available.
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

[varargout{1:nargout}] = tseries.myplot(@bar,varargin{:});

end
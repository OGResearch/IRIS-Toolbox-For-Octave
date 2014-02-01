function Fig = maxfigure(varargin)
% maxfigure  Create graphics window maximised across the entire screen.
%
% Syntax
% =======
%
%     Fig = maxfigure(...)
%
% Output arguments
% =================
%
% * `Fig` [ numeric ] - Handle to the figure created.
%
% Options
% ========
%
% See help on standar `figure` for the options available.
%
% Description
% ============
%
% The function `maxfigure` uses `get(0,'screenSize')` to determine the size
% of the screen, and sets the figure property `'outerPosition'`
% accordingly.
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

screenSize = get(0,'screenSize');
Fig = figure('outerPosition',screenSize,varargin{:});
    
end
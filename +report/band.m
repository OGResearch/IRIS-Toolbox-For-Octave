% band  Add new data with lower and upper bounds to graph or table.
%
% Syntax
% =======
%
%     P.series(Caption,X,Low,High,...)
%
% Input arguments
% ================
%
% * `P` [ struct ] - Report object created by the
% [`report.new`](report/new) function.
%
% * `Caption` [ char ] - Caption used as a default legend entry in a graph,
% or in the leading column in a table.
%
% * `X` [ tseries ] - Input data with the centre of the band.
%
% * `Low` [ tseries ] - Input data with lower bounds; can be specified
% either relative to the centre or absolute, see the option `'relative='`.
%
% * `High` [ tseries ] - Input data with upper bounds; can be specified
% either relative to the centre or absolute, see the option `'relative='`.
%
% Options for table and graph bands
% ==================================
%
% * `'low='` [ char | *'Low'* ] - (Inheritable from parent objects) Mark
% used to denote the lower bound.
%
% * `'high='` [ char | *'High'* ] - (Inheritable from parent objects) Mark
% used to denote the upper bound.
%
% * `'relative='` [ *`true`* | `false` ] - (Inheritable from parent objects) If
% true, the data for the lower and upper bounds are relative to the centre,
% i.e. the bounds will be added to the centre (in this case, `LOW` must be
% negative numbers and `HIGH` must be positive numbers). If false, the
% bounds are absolute data (in this case `LOW` must be lower than `X`, and
% `HIGH` must be higher than `X`).
%
% Options for table bands
% ========================
%
% * `'bandTypeface='` [ char | *`'\footnotesize'`* ] - (Inheritable from parent
% objects) LaTeX format string used to typeset the lower and upper bounds.%
%
% Options for graph bands
% ========================
%
% * `'plotType='` [ `'errorbar'` | *`'patch'`* ] - Type of plot used to draw
% the band.
%
% * `'relative='` [ *`true`* | `false` ] - (Inheritable from parent objects) If
% true the lower and upper bounds will be, respectively, subtracted from
% and added to to the middle line.
%
% * `'white='` [ numeric | *`0.8`* ] - (Inheritable from parent objects)
% Proportion of white colour mixed with the line colour and used to fill
% the area that depicts the band.
%
% See help on [`report/series`](report/series) for other options available.
%
% Generic options
% ================
%
% See help on [generic options](report/Contents) in report objects.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.
function [FF,AA,PDb] = qplot(QFile,D,Range,varargin)
% qplot  Quick report.
%
% Syntax
% =======
%
%     [FF,AA,PDb] = qplot(QFile,D,Range,...)
%
% Input arguments
% ================
%
% * `QFile` [ char ] - Name of the q-file that defines the contents of the
% individual graphs.
%
% * `D` [ struct ] - Database with input data.
%
% * `Range` [ numeric ] - Date range.
%
% Output arguments
% =================
%
% * `FF` [ numeric ] - Handles to figures created by `qplot`.
%
% * `AA` [ cell ] - Handles to axes created by `qplot`.
%
% * `PDb` [ struct ] - Database with actually plotted series.
%
% Options
% ========
%
% * `'addClick='` [ *`true`* | `false` ] - Make axes expand in a new
% graphics figure upon mouse click.
%
% * `'caption='` [ cellstr | @comment | *empty* ] - Strings that will be
% used for titles in the graphs that have no title in the q-file.
%
% * `'clear='` [ numeric | *empty* ] - Serial numbers of graphs (axes
% objects) that will not be displayed.
%
% * `'dbsave='` [ cellstr | *empty* ] - Options passed to `dbsave` when
% `'saveAs='` is used.
%
% * `'drawNow='` [ `true` | *`false`* ] - Call Matlab `drawnow` function
% upon completion of all figures.
%
% * `'grid='` [ *`true`* | `false` ] - Add grid lines to all graphs.
%
% * `'highlight='` [ numeric | cell | *empty* ] - Date range or ranges that
% will be highlighted.
%
% * `'interpreter='` [ *`'latex'`* | 'none' ] - Interpreter used in graph
% titles.
%
% * `'mark='` [ cellstr | *empty* ] - Marks that will be added to each
% legend entry to distinguish individual columns of multivariated tseries
% objects plotted.
%
% * `'overflow='` [ `true` | *`false`* ] - Open automatically a new figure
% window if the number of subplots exceeds the available total;
% `'overflow' = false` means an error will occur instead.
%
% * `'prefix='` [ char | *`'P%g_'`* ] - Prefix (a `sprintf` format string)
% that will be used to precede the name of each entry in the `PDb`
% database.
%
% * `'round='` [ numeric | *`Inf`* ] - Round the input data to this number of
% decimals before plotting.
%
% * `'saveAs='` [ char | *empty* ] - File name under which the plotted data
% will be saved either in a CSV data file or a PDF; you can use the
% `'dbsave='` option to control the options used when saving CSV.
%
% * `'style='` [ struct | *empty* ] - Style structure that will be applied
% to all figures and their children created by the `qplot` function.
%
% * `'subplot='` [ *'auto'* | numeric ] - Default subplot division of
% figures, can be modified in the q-file.
%
% * `'sstate='` [ struct | model | *empty* ] - Database or model object
% from which the steady-state values referenced to in the quick-report file
% will be taken.
%
% * `'style='` [ struct | *empty* ] - Style structure that will be applied
% to all created figures upon completion.
%
% * `'transform='` [ function_handle | *empty* ] - Function that will be
% used to trans
%
% * `'tight='` [ `true` | *`false`* ] - Make the y-axis in each graph
% tight.
%
% * `'vLine='` [ numeric | *empty* ] - Dates at which vertical lines will
% be plotted.
%
% * `'zeroLine='` [ `true` | *`false`* ] - Add a horizontal zero line to
% graphs whose y-axis includes zero.
%
% Description
% ============
%
% Example
% ========
%

%--------------------------------------------------------------------------

[FF,AA,PDb] = qreport.qreport(QFile,D,Range,'overflow=',true,varargin{:});

end
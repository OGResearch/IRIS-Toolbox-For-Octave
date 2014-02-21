function irisset(varargin)
% irisset  Change configurable IRIS options.
%
% Syntax
% =======
%
%     irisset(Option,Value)
%     irisset(Option,Value,Option,Value,...)
%
% Input arguments
% ================
%
% * `Option` [ char ] - Name of the IRIS configuration option that will be
% modified.
%
% * `Value` [ ... ] - New value that will be assigned to the option.
%
% Modifiable IRIS configuration options
% ======================================
%
% Dates and formats
% -------------------
%
% * `'dateFormat='` [ char | *`'YPF'`* ] - Date format used to display
% dates in the command window, CSV databases, and reports. Note that the
% default date format for graphs is controlled by the `'plotdateformat='`
% option. The default 'YFP' means that the year, frequency letter, and
% period is displayed. See also help on [`dat2str`](dates/dat2str) for more
% date formatting details. The `'dateformat='` option is also found in many
% IRIS functions whenever it is relevant, and can be used to overwrite the
% `'irisset='` settings.
%
% * `'freqLetters='` [ char | *`'YHQBMW'`* ] - Six letters used to
% represent the six possible frequencies of the IRIS dates: yearly,
% half-yearly, quarterly, bi-monthly, monthly, and weekly, such as the
% `'Q'` in `'2010Q1'` denoting a quarter.
%
% * `'months='` [ cellstr | *`{'January',...,'December'}`* ] - Twelve
% strings representing the names of the twelve months; this option can be
% used whenever you want to replace the default English names with your
% local language. .
%
% * `'plotDateFormat='` [ char |
% *`struct('yy','Y','hh','Y:P','qq','Y:P','bb','Y:P','mm','Y:P','ww','Y:P')`*
% ] - Default date formats used to display dates in graphs including graphs
% in reports. The default date formats are set individually for each of the
% 6 ate frequencies in a struct with the following fields: `.yy`, `.hh`,
% `.qq`, `.bb`, `.mm`, `.ww`. Dates with indeterminate frequency are
% printed as plain numbers.
%
% * `'tseriesFormat='` [ char | *empty* ] - Format string for displaying
% time series data on the screen. See help on the Matlab `sprintf` function
% for how to set up format strings. If empty the default format of the
% `num2str` function is used.
%
% * `tseriesMaxWSpace='` [ numeric | *`5`* ] - Maximum number of white
% spaces printed between individual columns of a multivariate tseries
% object on the screen.
%
% * `'standinMonth='` [ *`'first'`* | `'last'` | numeric ] - This option
% specifies which month will be used to represent lower-frequency periods
% (such as a quarters) when a month-displaying format is used in
% `'dateformat='`.
%
% External tools used by IRIS
% -----------------------------
%
% * `'pdflatexPath='` [ char ] - Location of the `pdflatex.exe` program.
% This program is called to compile report and publish m-files. By default,
% IRIS attempts to locate `pdflatex.exe` by running TeX's `kpsewhich`, and
% `which` on Unix platforms.
%
% * `'epstopdfPath='` [ char ] - Location of the `epstopdf.exe` program.
% This program is called to convert EPS graphics files to PDFs in
% reports.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

irisconfigmaster('set',varargin{:});

end
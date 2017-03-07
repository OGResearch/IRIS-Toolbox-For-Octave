function [FF,AA,PDb] = dbplot(D,List,Range,varargin)
% dbplot  Plot from database.
%
% Syntax
% =======
%
%     [FF,AA,PDb] = dbplot(D,List,Range,...)
%     [FF,AA,PDb] = dbplot(D,Range,List,...)
%
% Input arguments
% ================
%
% * `D` [ struct ] - Database with input data.
%
% * `List` [ cellstr ] - List of expressions (or labelled expressions) that
% will be evaluated and plotted in separate graphs.
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
% * `PDB` [ struct ] - Database with actually plotted series.
%
% Options
% ========
%
% * `'plotFunc='` [ @bar | @hist | *@plot* | @plotcmp | @plotpred | @stem |
% cell ] - Plot function used to create the graphs; use a cell array,
% `{plotFunc,...}` to specify extra input arguments that will be passed
% into the plotting function.
%
% See help on [`qreport/qplot`](qreport/qplot) for other options available.
%
% Description
% ============
%
% The function `dbplot` opens a new figure window (as many as needed to
% accommodate all graphs given the option `'subplot='`), and creates a
% graph for each entry in the cell array `List`.
%
% `List` can contain the names of the database time series, expression
% referring to the database fields evaluating to time series. You can also
% add labels (that will be displayed as graph titles) enclosed in double
% quotes and preceding the expressions. If you start the expression with a
% `^` (hat) symbol, the function specified in the `'transform='` option
% will not be applied to that expression.
%
% Example
% ========
%
%     dbplot(d,qq(2010,1):qq(2015,4), ...
%        {'x','"Series Y" y','^"Series z"'}, ...
%        'transform=',@(x) 100*(x-1));
%

if isnumeric(List) && iscellstr(Range)
    [List,Range] = deal(Range,List);
end

pp = inputParser();
pp.addRequired('D',@(x) isstruct(x));
pp.addRequired('List',@(x) iscellstr(x));
pp.addRequired('Range',@(x) isnumeric(x));
pp.parse(D,List,Range);

%--------------------------------------------------------------------------

[FF,AA,PDb] = qreport.qreport(List,D,Range,'overflow=',true,varargin{:});

end
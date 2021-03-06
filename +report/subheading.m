% subheading  Enter subheading in table.
%
% Syntax
% =======
%
%     P.subheading(CAP,...)
%
% Input arguments
% ================
%
% * `P` [ struct ] - Report object created by the
% [`report.new`](report/new) function.
%
% * `CAP` [ char ] - Text displayed as a subheading on a separate line in
% the table.
%
% Options
% ========
%
% * `'justify='` [ `'c'` | *`'l'`* | `'r'` ] - (Inheritable from parent objects)
% Horizontal alignment of the subheading (centre, left, right).
%
% * `'rowHighlight='` [ `true` | *`false`* ] - Highlight the entire row;
% because of a bug in the LaTex package `colortbl`, this option cannot be
% combined with the option `'highlight='` in [`report/table`](report/table).
%
% * `'separator='` [ char | *empty* ] - (Not inheritable from parent
% objects) LaTeX commands that will be inserted immediately after the end
% of the table row, i.e. appended to \\, within a tabular mode.
%
% * `'stretch='` [ *`true`* | `false` ] - (Inheritable from parent objects)
% Stretch the subheading text also across the data part of the table; if
% not the text will be contained within the initial descriptive columns.
%
% * `'typeface='` [ char | *`'\itshape\bfseries'`* ] - (Not inheritable from
% parent objects) LaTeX code specifying the typeface for the subheading; it
% must use the declarative forms (such as `\itshape`) and not the command
% forms (such as `\textit{...}`).
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

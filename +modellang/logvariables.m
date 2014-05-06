% !log_variables  List of log-linearised variables.
%
% Syntax
% =======
%
%     !log_variables
%         VariableName, VariableName, 
%         VariableName, ...
%
% Syntax with inverted list
% ==========================
%
%     !log_variables
%         !all_but
%         VariableName, VariableName, 
%         VariableName, ...
%
% Syntax with regular expression(s)
% ==================================
%
%     !log_variables
%         VariableName, VariableName, 
%         VariableName, ...
%         <REGEXP>, <REGEXP>, ...
%
% Description
% ============
%
% List all log-variables under this headings. Only measurement or
% transition variables can be declared as log-variables.
%
% In non-linear models, all variables are linearised around the steady
% state or a balanced-growth path. If you wish to log-linearise some of
% them instead, put them on a `!log_variables` list. You can also use the
% `!all_but` keyword to indicate an inverse list: all variables will be
% log-linearised except those listed.
%
% To create the list of log-variables, you can also use regular
% expressions, each enlosed in a pair of angle brackets, `<` and `>`. All
% measurement and transition variables whose names match one of the regular
% expressions will be declared as log-variables. See also help on regular
% expressions in the Matlab documentation.
%
% Example
% ========
%
% The following block of code will cause the variables `Y`, `C`, `I`, and
% `K` to be declared as log-variables, and hence log-linearised in the
% model solution, while `r` and `pie` will be linearised:
%
%     !transition_variables
%         Y, C, I, K, r, pie
%
%     !log_variables
%         Y, C, I, K
%
% You can do the same job by writing
%
%     !transition_variables
%         Y, C, I, K, r, pie
%
%     !log_variables
%         !all_but
%         r, pie
%
% Example
% ========
%
% We again achieve the same result as above, but now using a regular
% expression.
%
%     !transition_variables
%         Y, C, I, K, r, pie
%
%     !log_variables
%         <[A-Z]\w*>
%
% The regular expression `[A-Z]\w*` selects all variables whose names start
% with an upper-case letter. Hence, again the variables `Y`, `C`, `I`, and
% `K` will be declared as log-variables.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

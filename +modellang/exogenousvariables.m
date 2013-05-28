% !exogenous_variables  List of exogenous variables.
%
% Syntax
% =======
%
%     !exogenous_variables
%         Variable_Name, Variable_Name, ...
%         ...
%
% Syntax with descriptors
% ========================
%
%     !exogenous_variables
%         Variable_Name, Variable_Name, ...
%         'Description of the variable...' Variable_Name
%
% Syntax with steady-state values
% ================================
%
%     !exogenous_variables
%         Variable_Name, Variable_Name, ...
%         Variable_Name = Value
%
% Description
% ============
% 
% The `!exogenous_variables` keyword starts a new declaration block for
% exogenous variables, i.e. variables that can appear only in
% [`!dtrends`](modellang/dtrends) equations. The names of the variables
% must be separated by commas, semi-colons, or line breaks. You can have as
% many declaration blocks as you wish in any order in your model file: They
% all get combined together when you read the model file in. Each variable
% must be declared (exactly once).
% 
% You can add descriptors to the variables (enclosed in single or double
% quotes, preceding the name of the variable); these will be stored in, and
% accessible from, the model object. You can also assign steady-state
% values to the variables straight in the model file (following an equal
% sign after the name of the variable); this is, though, rather rare and
% unnecessary practice because you can assign and change steady-state
% values more conveniently in the model object.
% 
% Example
% ========
% 
%     !exogenous_variables
%         X, 'Tax effects' Y
%         'Population growth effects' Z = 0 + 0.5i;
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.


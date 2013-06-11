% !parameters  List of parameters.
%
% Syntax
% =======
%
%     !parameters
%         parameter_name, parameter_name, ...
%         ...
%
% Syntax with descriptors
% ========================
%
%     !parameters
%         parameter_name, parameter_name, ...
%         'Description of the parameter...' parameter_name
%
% Syntax with steady-state values
% ================================
%
%     !parameters
%         parameter_name, parameter_name, ...
%         parameter_name = value
%
% Description
% ============
% 
% The `!parameters` keyword starts a new declaration block for parameters;
% the names of the parameters must be separated by commas, semi-colons, or
% line breaks. You can have as many declaration blocks as you wish in any
% order in your model file: They all get combined together when you read
% the model file in. Each parameters must be declared (exactly once).
% 
% You can add descriptors to the parameters (enclosed in single or double
% quotes, preceding the name of the parameter); these will be stored in,
% and accessible from, the model object. You can also assign parameter
% values straight in the model file (following an equal sign after the name
% of the parameter); this is, though, rather rare and unnecessary practice
% because you can assign and change parameter values more conveniently in
% the model object.
% 
% Example
% ========
% 
%     !parameters
%         alpha, 'Discount factor' beta
%         'Labour share' gamma = 0.60
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.


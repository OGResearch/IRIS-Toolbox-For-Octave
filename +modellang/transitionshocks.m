% !transition_shocks  List of transition shocks.
%
% Syntax
% =======
%
%     !transition_shocks
%         shock_name, shock_name, ...
%         ...
%
% Short-cut syntax
% =================
%
%     !shocks
%         shock_name, shock_name, ...
%         ...
%
% Syntax with descriptors
% ========================
%
%     !transition_shocks
%         shock_name, shock_name, ...
%         'Description of the shock...' shock_name
%
% Description
% ============
% 
% The `!transition_shocks` keyword starts a new declaration block for
% transition shocks (i.e. shocks to transition equation); the names of the
% shocks must be separated by commas, semi-colons, or line breaks. You
% can have as many declaration blocks as you wish in any order in your
% model file: They all get combined together when you read the model file
% in. Each shock must be declared (exactly once).
% 
% You can add descriptors to the shocks (enclosed in single or double
% quotes, preceding the name of the shock); these will be stored in, and
% accessible from, the model object.
% 
% Example
% ========
% 
%     !transition_shocks
%         e1, 'Aggregate supply shock' e2
%         e3


% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.


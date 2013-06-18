% min  Define the loss function in a time-consistent optimal policy model.
%
% Syntax
% =======
%
%     min(DISC) EXPRESSION;
%
% Syntax for exact non-linear simulations
% ========================================
% 
%     min#(DISC) EXPRESSION;
%
% Description
% ============
%
% The loss function must be types as one of the transition equations. The
% `DISC` is a parameter or an expression defining the discount factor
% (applied to future dates), the `EXPRESSION` defines the loss fuction
% proper.
%
% If you use the `min#(DISC)` syntax, all equations created by
% differentiating the lagrangian w.r.t. individual variables will be
% earmarked for exact non-linear simulations provided the respective
% derivative is nonzero.
%
% Example
% ========
%
% This is a simple model file with a Phillips curve and a quadratic loss
% function.
%
%     !transition_variables
%         x, pi
%
%     !transition_shocks
%         u
%
%     !parameters
%         alpha, beta, gamma
%
%     !transition_equations
%         min(beta) pi^2 + lambda*x^2;
%         pi = alpha*pi{-1} + (1-alpha)*pi{1} + gamma*y + u;
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

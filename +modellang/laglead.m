% {...}  Lag or lead.
%
% Syntax
% =======
%
%     VARIABLE_NAME{-lag}
%     VARIABLE_NAME{lead}
%     VARIABLE_NAME{+lead}
%
% Description
% ============
%
% To create a lag or a lead of a variable, use a pair of curly brackets.
%
% Example
% ========
%
%     !transition_equations
%         x = rho*x{-1} + epsilon_x;
%         pi = 1/2*pie{-1} + 1/2*pie{1} + gamma*y + epsilon_pi;
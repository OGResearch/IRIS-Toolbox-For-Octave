% &  Reference to the steady-state level of a variable.
%
% Syntax
% =======
%
%     &Variable_Name
%     $Variable_Name
%
% Description
% ============
%
% Use either a `&` or `$` sign in front of a variable name to create a
% reference to that variable's steady-state level in transition or
% measurement equations. The two signs, `&` and `$`, are interchangeable.
%
% The steady-state reference will be replaced
%
% * with the variable itself at the time model's steady state is being
% calculated, i.e. when calling the function [`sstate`](model/sstate);
%
% * with the actually assigned steady-state value at the time the model is
% being solved, i.e. when calling the function ['solve'](model/solve)'.
%
% Example
% ========
%
%     x = rho*x{-1} + (1-rho)*&x + epsilon_x !! x = 1;
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

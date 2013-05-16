% !dtrends  Block of deterministic trend equations.
%
% Syntax for linearised measurement variables
% ============================================
%
%     !dtrends
%         VARIABLE_NAME += EXPRESSION;
%         VARIABLE_NAME += EXPRESSION;
%         VARIABLE_NAME += EXPRESSION;
%         ...
%
% Syntax for log-linearised measurement variables
% ================================================
%
%     !dtrends
%         log(VARIABLE_NAME) += EXPRESSION;
%         log(VARIABLE_NAME) += EXPRESSION;
%         log(VARIABLE_NAME) += EXPRESSION;
%         ...
%
% Syntax with equation labels
% ============================
%
%     !dtrends
%         'Equation label' VARIABLE_NAME += EXPRESSION;
%         'Equation label' LOG(VARIABLE_NAME) += EXPRESSION;
%
% Description
% ============
%
% Example
% ========
%
%     !dtrends
%         Infl += pi_;
%         Rate += rho_ + pi_;
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

% !dtrends  Block of deterministic trend equations.
%
% Syntax for linearised measurement variables
% ============================================
%
%     !dtrends
%         Variable_Name += Expression;
%         Variable_Name += Expression;
%         Variable_Name += Expression;
%         ...
%
% Syntax for log-linearised measurement variables
% ================================================
%
%     !dtrends
%         log(Variable_Name) += Expression;
%         log(Variable_Name) += Expression;
%         log(Variable_Name) += Expression;
%         ...
%
% Syntax with equation labels
% ============================
%
%     !dtrends
%         'Equation label' Variable_Name += Expression;
%         'Equation label' LOG(Variable_Name) += Expression;
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
% -Copyright (c) 2007-2014 IRIS Solutions Team.

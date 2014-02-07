function D = reporting(This,varargin)
% reporting  Run reporting equations.
%
% Syntax
% =======
%
%     D = reporting(M,D,Range,...)
%
% Input arguments
% ================
%
% * `M` [ model ] - Model object with reporting equations.
%
% * `D` [ struct ] - Input database that will be used to evaluate the
% reporting equations.
%
% * `Range` [ numeric ] - Date range on which the reporting equations will
% be evaluated.
%
% Output arguments
% =================
%
% * `D` [ struct ] - Output database with reporting variables.
%
% Options
% ========
%
% * `'dynamic='` [ *`true`* | `false` ] - If true, equations will be
% evaluated period by period allowing for own lags; if false, equations
% will be evaluated en bloc for all periods.
%
% * `'merge='` [ *`true`* | `false` ] - Merge output database with input
% datase.
%
% Description
% ============
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

D = reporting(This.outside,varargin{:});

end
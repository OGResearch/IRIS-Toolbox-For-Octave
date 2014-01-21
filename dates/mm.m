function Dat = mm(varargin)
% mm  IRIS serial date number for monthly date.
%
% Syntax
% =======
%
%     Dat = mm(Y)
%     Dat = mm(Y,M)
%
% Input arguments
% ================
%
% * `Y` [ numeric ] - Years.
%
% * `M` [ numeric ] - Months; if omitted, first month (January) is assumed.
%
% Output arguments
% =================
%
% * `Dat` [ numeric ] - IRIS serial date numbers representing the input
% months.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

Dat = datcode(12,varargin{:});

end
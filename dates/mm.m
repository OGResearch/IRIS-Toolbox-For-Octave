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
% * `Y` [ numeric ] - Year.
%
% * `M` [ numeric ] - Month; if omitted, first month (January) is assumed.
%
% Output arguments
% =================
%
% * `Dat` [ numeric ] - IRIS serial date number representing the monthly
% date.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

Dat = datcode(12,varargin{:});

end
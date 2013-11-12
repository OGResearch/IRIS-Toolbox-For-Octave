function dat = mm(varargin)
% mm  IRIS serial date numbers for dates with monthly frequency.
%
% Syntax
% =======
%
%     d = mm(y)
%     d = mm(y,m)
%
% Input arguments
% ================
%
% * `y` [ numeric ] - Years.
%
% * `m` [ numeric ] - Months; if missing, first month (January) is assumed.
%
% Output arguments
% =================
%
% * `d` [ numeric ] - IRIS serial date numbers representing the input
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

%**************************************************************************

dat = datcode(12,varargin{:});

end
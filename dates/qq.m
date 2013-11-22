function dat = qq(varargin)
% qq  IRIS serial date numbers for dates with quarterly frequency.
%
% Syntax
% =======
%
%     d = qq(y)
%     d = qq(y,q)
%
% Input arguments
% ================
%
% * `y` [ numeric ] - Years.
%
% * `q` [ numeric ] - Quarters; if missing, first quarter is assumed.
%
% Output arguments
% =================
%
% * `d` [ numeric ] - IRIS serial date numbers representing the input
% quarterly dates.
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

dat = datcode(4,varargin{:});

end

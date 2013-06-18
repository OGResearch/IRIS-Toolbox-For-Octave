function dat = yy(varargin)
% yy  IRIS serial date numbers for dates with yearly frequency.
%
% Syntax
% =======
%
%     d = yy(y)
%
% Input arguments
% ================
%
% * `y` [ numeric ] - Years.
%
% Output arguments
% =================
%
% * `d` [ numeric ] - IRIS serial date numbers representing the input years.
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

dat = datcode(1,varargin{:});

end

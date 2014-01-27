function Dat = yy(varargin)
% yy  IRIS serial date number for yearly date.
%
% Syntax
% =======
%
%     Dat = yy(Y)
%
% Input arguments
% ================
%
% * `Y` [ numeric ] - Year.
%
% Output arguments
% =================
%
% * `Dat` [ numeric ] - IRIS serial date numbers representing the yearly
% date.
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

Dat = datcode(1,varargin{:});

end

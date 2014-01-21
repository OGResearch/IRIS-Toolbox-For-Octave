function Dat = yy(varargin)
% yy  IRIS serial date numbers for yearly dates.
%
% Syntax
% =======
%
%     Dat = yy(Y)
%
% Input arguments
% ================
%
% * `Y` [ numeric ] - Years.
%
% Output arguments
% =================
%
% * `Dat` [ numeric ] - IRIS serial date numbers representing the input years.
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

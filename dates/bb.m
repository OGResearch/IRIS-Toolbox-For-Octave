function Dat = bb(varargin)
% bb  IRIS serial date number for bimonthly date.
%
% Syntax
% =======
%
%     Dat = bb(Y)
%     Dat = bb(Y,B)
%
% Input arguments
% ================
%
% * `Y` [ numeric ] - Years.
%
% * `B` [ numeric ] - Bimonth; if omitted, first bimonth
% (January-February) is assumed.
%
% Output arguments
% =================
%
% * `Dat` [ numeric ] - IRIS serial date numbers representing the
% bimonthly date.
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

Dat = datcode(6,varargin{:});

end

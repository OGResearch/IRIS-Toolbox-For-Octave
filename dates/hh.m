function Dat = hh(varargin)
% hh  IRIS serial date numbers for dates with half-yearly frequency.
%
% Syntax
% =======
%
%     Dat = hh(Y)
%     Dat = hh(Y,H)
%
% Input arguments
% ================
%
% * `Y` [ numeric ] - Years.
%
% * `H` [ numeric ] - Half-years; if missing, first half-year is assumed.
%
% Output arguments
% =================
%
% * `Dat` [ numeric ] - IRIS serial date numbers representing the input
% half-years.
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

Dat = datcode(2,varargin{:});

end

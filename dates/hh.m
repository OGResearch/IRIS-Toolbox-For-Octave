function Dat = hh(varargin)
% hh  IRIS serial date number for half-yearly date.
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
% * `Y` [ numeric ] - Year.
%
% * `H` [ numeric ] - Half-year; if missing, first half-year (January to
% June) is assumed.
%
% Output arguments
% =================
%
% * `Dat` [ numeric ] - IRIS serial date numbers representing the
% half-yearly date.
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

function Dat = zz(varargin)
% zz  IRIS serial date numbers half-yearly dates.
%
% Syntax
% =======
%
%     Dat = zz(Y)
%     Dat = zz(Y,H)
%
% Output arguments
% =================
%
% * `Dat` [ numeric ] - IRIS serial date numbers.
%
% Input arguments
% ================
%
% * `Y` [ numeric ] - Years.
%
% * `H` [ numeric ] - Half-years; if missing, first half-year is assumed.
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

% ##### Dec 2013 OBSOLETE and scheduled for removal.
utils.warning('obsolete', ...
    ['The function zz() is obsolete ', ...
    'and will be removed from IRIS in a future release. ', ...
    'Use hh() instead.']);

Dat = datcode(2,varargin{:});

end

function Dat = qq(varargin)
% qq  IRIS serial date number for quarterly date.
%
% Syntax
% =======
%
%     Dat = qq(Y)
%     Dat = qq(Y,Q)
%
% Input arguments
% ================
%
% * `Y` [ numeric ] - Year.
%
% * `Q` [ numeric ] - Quarter; if omitted, first quarter is assumed.
%
% Output arguments
% =================
%
% * `Dat` [ numeric ] - IRIS serial date number representing the quarterly
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

Dat = datcode(4,varargin{:});

end

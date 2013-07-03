function varargout = zztoday(varargin)
% zztoday  IRIS serial date number for current half-year.
%
% Syntax
% =======
%
%     Dat = zztoday()
%
% Output arguments
% =================
%
% * `Dat` [ numeric ] - IRIS serial date number for current half-year.
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

[varargout{1:nargout}] = hhtoday(varargin{:});

end
function varargout = qplot(varargin)
% qplot  Shortcut for qreport.qplot.
%
% See help on [`qreport.qplot`](qreport/qplot).

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

[varargout{1:nargout}] = qreport.qplot(varargin{:});

end

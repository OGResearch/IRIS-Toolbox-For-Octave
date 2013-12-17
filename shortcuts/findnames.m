function varargout = findnames(varargin)
% findnames  Shortcut for strfun.findnames.
%
% See help on [`strfun.findnames`](strfun/findnames).
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

[varargout{1:nargout}] = strfun.findnames(varargin{:});

end

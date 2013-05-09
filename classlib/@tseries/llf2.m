function varargout = llf2(varargin)
% llf2  Swap output arguments of the local linear trend filter with tunes.
%
% See help on [`tseries/llf`](tseries/llf).

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

% BWF2, HPF2, LLF2

%--------------------------------------------------------------------------

[varargout{[2,1,3,4]}] = llf(varargin{:});

end


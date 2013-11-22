function varargout = bwf2(varargin)
% bwf  Swap output arguments of the Butterworth filter with tunes.
%
% See help on [`tseries/bwf`](tseries/bwf).

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

% BWF2, HPF2, LLF2

%--------------------------------------------------------------------------

[varargout{[2,1]}] = bwf(varargin{:});

end
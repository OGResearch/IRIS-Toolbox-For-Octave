function varargout = hpf2(varargin)
% hpf2  Swap output arguments of the Hodrick-Prescott filter with tunes.
%
% See help on [`tseries/hpf`](tseries/hpf).

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

% BWF2, HPF2, LLF2

%--------------------------------------------------------------------------

[varargout{[2,1,3,4]}] = hpf(varargin{:});

end


function y = freq(x)
% freq  Frequency of a tseries object.
%
% Syntax
% =======
%
%     f = freq(x)
%
% Input arguments
% ================
%
% * `x` [ tseries ] - Tseries object.
%
% Output arguments
% =================
%
% * `f` [ 0 | 1 | 2 | 4 | 6 | 12 ] - Frequency of observations in the input
% tseries object (`f` is the number of periods within a year).
%
% Description
% ============
%
% The `freq` function is equivalent to calling
%
%     get(x,'freq')
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%**************************************************************************

y = datfreq(x.start);

end
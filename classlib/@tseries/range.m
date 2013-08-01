function y = range(x)
% range  Date range from the first to the last available observation.
%
% Syntax
% =======
%
%     rng = range(x)
%
% Input arguments
% ================
%
% * `x` [ tseries ] - Tseries object.
%
% Output arguments
% =================
%
% * `rng` [ numeric ] - Vector of IRIS serial date numbers representing the
% range from the first to the last available observation in the input
% tseries.
%
% Description
% ============
%
% The `range` function is equivalent to calling
%
%     get(x,'range')
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%**************************************************************************

if isempty(x.data)
    y = [];
else
    y = x.start : x.start + size(x.data,1) - 1;
end

end
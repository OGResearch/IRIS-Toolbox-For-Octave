function x = empty(x)
% empty  Empty tseries object preserving its size in 2nd and higher dimensions.
%
% Syntax
% =======
%
%     x = empty(x)
%
% Input arguments
% ================
%
% * `x` [ tseries ] - Tseries object that will be emptied.
%
% Output arguments
% =================
%
% * `x` [ tseries ] - Empty tseries object with the 2nd and higher
% dimensions the same size as the input tseries object, and comments
% preserved.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%**************************************************************************

x.start = NaN;
tmpsize = size(x.data);
x.data = zeros([0,tmpsize(2:end)]);
% Comments are preserved.

end

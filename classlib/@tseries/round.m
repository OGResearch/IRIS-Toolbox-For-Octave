function X = round(X,varargin)
% round  Round tseries values to specified number of decimals.
%
% Syntax
% =======
%
%     X = round(X)
%     X = round(X,Dec)
%     X = round(X,Dec,'significant')
%
% Input arguments
% ================
%
% * `X` [ tseries ] - Tseries object whose data will be rounded.
%
% * `Dec` [ numeric ] - Number of decimals to which the tseries data will
% be rounded; if not specified, the data are rounded to nearest integer.
%
% * `'significant'` - See documentation on the built-in Matlab function
% `round`; works only in R2014b or later.
%
% Output arguments
% =================
%
% * `X` [ tseries ] - Rounded tseries object.
%
% Description
% ============
%
% The number of decimals, to which the tseries data will be rounded, can be
% positive, zero, or negative.
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

try %#ok<TRYNC>
    X.data = round(X.data,varargin{:});
    return
end

try
    Dec = varargin{1};
catch %#ok<CTCH>
    Dec = 0;
end

%--------------------------------------------------------------------------

if Dec ~= 0
    factor = 10^Dec;
    X.data = X.data * factor;
end
X.data = round(X.data);
if Dec ~= 0
    X.data = X.data / factor;
end

end

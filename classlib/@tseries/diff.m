function X = diff(X,K)
% diff  First difference.
%
% Syntax
% =======
%
%     X = diff(X)
%     X = diff(X,K)
%
% Input arguments
% ================
%
% * `X` [ tseries ] - Input tseries object.
%
% * `K` [ numeric ] - Number of periods over which the first difference
% will be computed; `Y = X - X{K}`. Note that `K` must be a negative number
% for the usual backward differencing. If not specified, `K` will be set to
% `-1`.
%
% Output arguments
% =================
%
% * `X` [ tseries ] - First difference of the input data.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

% diff, df, pct, apct

try
    K; %#ok<VUNUS>
catch %#ok<CTCH>
    K = -1;
end

pp = inputParser();
if ismatlab
pp.addRequired('X',@(isArg)is.tseries(isArg));
pp.addRequired('K',@(isArg)is.numericscalar(isArg));
pp.parse(X,K);
else
pp = pp.addRequired('X',@(isArg)is.tseries(isArg));
pp = pp.addRequired('K',@(isArg)is.numericscalar(isArg));
pp = pp.parse(X,K);
end

%--------------------------------------------------------------------------

X = unop(@tseries.mydiff,X,0,K);

end
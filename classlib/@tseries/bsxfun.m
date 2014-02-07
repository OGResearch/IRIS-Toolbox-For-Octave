function X = bsxfun(Func,X,Y)
% bsxfunc  Standard BSXFUN implemented for tseries objects.
%
% Syntax
% =======
%
%     Z = bsxfun(Func,X,Y)
%
% Input arguments
% ================
%
% * `Func` [ function_handle ] - Function that will be applied to the input
% series, `FUN(X,Y)`.
%
% * `X` [ tseries | numeric ] - Input time series or numeric array.
%
% * `Y` [ tseries | numeric ] - Input time series or numeric array.
%
% Output arguments
% =================
%
% * `Z` [ tseries ] - Result of `Func(X,Y)` with `X` and/or `Y` expanded
% properly in singleton dimensions.
%
% Description
% ============
%
% See help on built-in `bsxfun` for more help.
%
% Example
% ========
%
% We create a multivariate time series and subtract mean from its
% individual columns.
%
%     x = tseries(1:10,rand(10,4));
%     xx = bsxfun(@minus,x,mean(x));
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

% Validate input arguments.
pp = inputParser();
if ismatlab
pp.addRequired('Func',@is.func);
pp.addRequired('X',@(x) isa(x,'tseries') || isnumeric(x));
pp.addRequired('Y',@(x) isa(x,'tseries') || isnumeric(x));
pp.parse(Func,X,Y);
else
pp = pp.addRequired('Func',@is.func);
pp = pp.addRequired('X',@(x) isa(x,'tseries') || isnumeric(x));
pp = pp.addRequired('Y',@(x) isa(x,'tseries') || isnumeric(x));
pp = pp.parse(Func,X,Y);
end

%--------------------------------------------------------------------------

if isa(X,'tseries') && isa(Y,'tseries')
    range = min(X.start,Y.start) : ...
        max(X.start+size(X.data,1),Y.start+size(Y.data,1))-1;
    data1 = rangedata(X,range);
    data2 = rangedata(Y,range);
    nPer = length(range);
    co = [];
    start = range(1);
elseif isa(X,'tseries')
    data1 = X.data;
    data2 = Y;
    nPer = size(X.data,1);
    co = X.Comment;
    start = X.start;
else
    data1 = X;
    data2 = Y.data;
    nPer = size(Y.data,1);
    co = Y.Comment;
    start = Y.start;
end

data = bsxfun(Func,data1,data2);

if size(data,1) ~= nPer
    utils.error('tseries', ...
        ['Result of BSXFUN must preserve ', ...
        'the size of the input tseries in 1st dimension.']);
end

if isa(X,'tseries')
    X = replace(X,data,start,co);
else
    X = replace(Y,data,start,co);
end

end
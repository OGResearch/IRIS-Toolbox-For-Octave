function X = normalise(X,NORMDATE,varargin)
% normalise  Normalise (or rebase) data to particular date.
%
% Syntax
% =======
%
%     x = normalise(x)
%     x = normalise(x,normdate,...)
%
% Input arguments
% ================
%
% * `x` [ tseries ] -  Input tseries object that will be normalised.
%
% * `normdate` [ numeric | 'start' | 'end' | 'nanstart' | 'nanend' ] - Date
% relative to which the input data will be normalised; if not specified,
% 'nanstart' (the first date for which all columns have an observation)
% will be used.
%
% Output arguments
% =================
%
% * `x` [ tseries ] - Normalised tseries object.
%
% Options
% ========
%
% * `'mode='` [ 'add' | *'mult'* ]  - Additive or multiplicative
%     normalisation.
% Description
% ============
%
% Example
% ========

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

options = passvalopt('tseries.normalise',varargin{:});

if nargin == 1
    NORMDATE = 'nanstart';
end

%**************************************************************************

if strncmpi(options.mode,'add',3)
    func = @minus;
else
    func = @rdivide;
end

if ischar(NORMDATE)
    NORMDATE = get(X,NORMDATE);
end

tmpsize = size(X.data);
X.data = X.data(:,:);

y = mygetdata(X,NORMDATE);
for i = 1 : size(X.data,2)
    X.data(:,i) = func(X.data(:,i),y(i));
end

if length(tmpsize) > 2
    X.data = reshape(X.data,tmpsize);
end

X = mytrim(X);

end

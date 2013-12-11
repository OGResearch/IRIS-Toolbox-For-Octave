function X = expsmooth(X,BETA,Range,varargin)
% ews  Exponential smoothing.
%
% Syntax
% =======
%
%     X = expsmooth(X,BETA,...)
%
% Input arguments
% ================
%
% * `X` [ tseries ] - Input time series.
%
% * `Beta` [ numeric ] - Exponential factor.
%
% Output arguments
% =================
%
% * `X` [ tseries ] - Exponentially smoothed series.
%
%
% Options
% ========
%
% * `'init='` [ numeric | *`NaN`* ] - Add this value before the first
% observation to initialise the smoothing.
%
% * `'log='` [ `true` | *`false`* ] - Logarithmise the data before
% filtering, de-logarithmise afterwards.
%
% Description
% ============
%
% Examples
% =========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

if ~exist('RANGE','var')
    Range = Inf;
end

opt = passvalopt('tseries.expsmooth',varargin{:});

%--------------------------------------------------------------------------

X = resize(X,Range);

if opt.log
    X.data = log(X.data);
end

X.data = tseries.myexpsmooth(X.data,BETA,opt.init);

if opt.log
    X.data = exp(X.data);
end

X = mytrim(X);

end
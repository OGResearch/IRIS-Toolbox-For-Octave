function [This,TT,TS] = trend(This,Range,varargin)
% trend  Estimate a time trend.
%
% Syntax
% =======
%
%     X = trend(X,range)
%
% Input arguments
% ================
%
% * `X` [ tseries ] - Input time series.
%
% * `Range` [ tseries ] - Range for which the trend will be computed.
%
% Output arguments
% =================
%
% * `X` [ tseries ] - Output trend time series.
%
% Options
% ========
%
% * `'break='` [ numeric | *empty* ] - Vector of breaking points at which
% the trend may change its slope.
%
% * `'connect='` [ *`true`* | `false` ] - Calculate the trend by connecting
% the first and the last observations.
%
% * `'diff='` [ `true` | *`false`* ] - Estimate the trend on differenced
% data.
%
% * `'log='` [ `true` | *`false`* ] - Logarithmise the input data,
% de-logarithmise the output data.
%
% * `'season='` [ `true` | *`false`* | `2` | `4` | `6` | `12` ] - Include
% deterministic seasonal factors in the trend.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

if nargin < 2
    Range = Inf;
end

% Parse required input arguments.
pp = inputParser();
if ismatlab
pp.addRequired('X',@is.tseries);
pp.addRequired('Range',@isnumeric);
pp.parse(This,Range);
else
pp = pp.addRequired('X',@is.tseries);
pp = pp.addRequired('Range',@isnumeric);
pp = pp.parse(This,Range);
end

% Parse options.
opt = passvalopt('tseries.trend',varargin{:});

%--------------------------------------------------------------------------

[ThisData,Range] = rangedata(This,Range);
tmpSize = size(ThisData);
ThisData = ThisData(:,:);

% Compute the trend.
[ThisData,TTdata,TSdata] = tseries.mytrend(ThisData,Range(1),opt);
ThisData = reshape(ThisData,tmpSize);

% Output data.
This = replace(This,ThisData,Range(1));
This = mytrim(This);
if nargout > 1
    TT = replace(This,reshape(TTdata,tmpSize));
    TT = mytrim(TT);
    if nargout > 2
        TS = replace(This,reshape(TSdata,tmpSize));
        TS = mytrim(TS);
    end
end

end
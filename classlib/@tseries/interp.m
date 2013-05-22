function X = interp(X,RANGE,varargin)
% interp  Interpolate missing observations.
%
% Syntax
% =======
%
%     X = interp(X,RANGE,...)
%
% Input arguments
% ================
%
% * `X` [ tseries ] - Input time series.
%
% * `RANGE` [ tseries ] - Date range on which any missing, i.e. NaN,
% observations will be interpolated.
%
% Output arguments
% =================
%
% * `x` [ tseries ] - Tseries object with the missing observations
% interpolated.
%
% Options
% ========
%
% * `'method='` [ char | *`'cubic'`* ] - Any valid method accepted by the
% built-in `interp1` function.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

opt = passvalopt('tseries.interp',varargin{:});

try
    RANGE; %#ok<VUNUS>
catch %#ok<CTCH>
    RANGE = Inf;
end

%********************************************************************

if any(isinf(RANGE))
   RANGE = get(X,'range');
elseif ~isempty(RANGE)
   RANGE = RANGE(1) : RANGE(end);
   X.data = rangedata(X,RANGE);
   X.start = RANGE(1);
else
   X = empty(X);
   return
end

data = X.data(:,:);
grid = dat2grid(RANGE);
grid = grid - grid(1);
for i = 1 : size(data,2)
   index = ~isnan(data(:,i));
   if any(~index)
      data(~index,i) = interp1(...
         grid(index),data(index,i),grid(~index),opt.method,'extrap');   
   end
end

X.data(:,:) = data;

end
function [Rmse,Pe] = rmse(Obs,Pred,Range,varargin)
% rmse  Compute RMSE for given observations and predictions.
%
% Syntax
% =======
%
%     [Rmse,Pe] = rmse(Obs,Pred)
%     [Rmse,Pe] = rmse(Obs,Pred,Range,...)
%
% Input arguments
% ================
% 
% * `Obs` [ tseries ] - Input data with observations.
%
% * `Pred` [ tseries ] - Input data with predictions (a different prediction
% horizon in each column); `Pred` is typically the outcome of the Kalman
% filter, [`model/filter`](model/filter) or [`VAR/filter`](VAR/filter),
% called with the option `'ahead='`.
%
% * `Range` [ numeric | `Inf` ] - Date range on which the RMSEs will be
% evaluated; `Inf` means the entire possible range available.
%
% Output arguments
% =================
%
% * `Rmse` [ numeric ] - Numeric array with RMSEs for each column of
% `Pred`.
%
% * `Pe` [ tseries ] - Prediction errors, i.e. the difference `Obs - Pred`
% evaluated within `Range`.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

try
    Range; %#ok<VUNUS>
catch %#ok<CTCH>
    Range = Inf;
end

pp = inputParser();
pp.addRequired('Obs', ...
    @(x) isa(x,'tseries') && ndims(x) == 2 && size(x,2) == 1); %#ok<ISMAT>
pp.addRequired('Pred',@(x) isa(x,'tseries'));
pp.addRequired('Range',@isnumeric);
pp.parse(Obs,Pred,Range);

%--------------------------------------------------------------------------

Obs = resize(Obs,Range);
Pred = resize(Pred,Range);
Pe = Obs - Pred;

Mse = tseries.mynanmean(Pe.data.^2,1);
Rmse = sqrt(Mse);

end
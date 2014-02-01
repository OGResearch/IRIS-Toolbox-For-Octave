function [C,R] = acf(X,varargin)
% acf  Sample autocovariance and autocorrelation functions.
%
% Syntax
% =======
%
%     [C,R] = acf(X)
%     [C,R] = acf(X,Dates,...)
%
% Input arguments
% ================
%
% * `X` [ tseries ] - Tseries object.
%
% * `Dates` [ numeric | Inf ] - Dates or date range on which tseries data
% will be used.
%
% Output arguments
% =================
%
% * `C` [ numeric ] - Auto-/cross-covariance matrices.
%
% * `R` [ numeric ] - Auto-/cross-correlation matrices.
%
% Options
% ========
%
% * `'demean='` [ *`true`* | `false` ] - Remove mean from the data before
% computing the ACF.
%
% * `'order='` [ numeric | *`0`* ] - Order up to which the ACF will be
% computed.
%
% * `'smallSample='` [ *`true`* | `false` ] - Adjust degrees of freedom for
% small samples.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%#ok<*VUNUS>
%#ok<*CTCH>

if ~isempty(varargin) && ~ischar(varargin{1})
    Dates = varargin{1};
    varargin(1) = [];
else
    Dates = Inf;
end

opt = passvalopt('tseries.acf',varargin{:});

%--------------------------------------------------------------------------

if isequal(Dates,Inf)
    data = mygetdata(X,'min');
else
    data = mygetdata(X,Dates);
end

if ndims(data) > 3
    data = data(:,:,:);
end

C = covfun.acovfsmp(data,opt);
if nargout > 1
    % Convert covariances to correlations.
    R = covfun.cov2corr(C,'acf');
end

end

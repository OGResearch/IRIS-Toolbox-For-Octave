function varargout = bwf(X,Order,varargin)
% bwf  Butterworth filter with tunes.
%
% Syntax
% =======
%
%     [T,C,CutOff,Lambda] = bwf(X,Order)
%     [T,C,CutOff,Lambda] = bwf(X,Order,Range,...)
%
% Syntax with output arguments swapped
% =====================================
%
%     [T,C,CutOff,Lambda] = bwf2(X,Order)
%     [T,C,CutOff,Lambda] = bwf2(X,Order,Range,...)
%
% Input arguments
% ================
%
% * `X` [ tseries ] - Input tseries object that will be filtered.
%
% * `Order` [ numeric ] - Order of the Butterworth filter; note that
% `Order=2` reproduces the Hodrick-Prescott filter (`hpf`) and `Order=1`
% reproduces the local linear filter (`llf`).
%
% * `Range` [ numeric ] - Date Range on which the input data will be
% filtered; `Range` can be `Inf`, `[startdata,Inf]`, or `[-Inf,enddate]`;
% if not specifired, `Inf` (i.e. the entire available Range of the input
% series) is used.
%
% Output arguments
% =================
%
% * `T` [ tseries ] - Lower-frequency (trend) component.
%
% * `C` [ tseries ] - Higher-frequency (cyclical) component.
%
% * `CutOff` [ numeric ] - Cut-off periodicity; periodicities above the
% cut-off are attributed to trends, periodicities below the cut-off are
% attributed to gaps.
%
% * `Lambda` [ numeric ] - Smoothing parameter actually used; this output
% argument is useful when the option `'CutOff='` is used instead of
% `'Lambda='`.
%
% Options
% ========
%
% * `'CutOff='` [ numeric | *empty* ] - Cut-off periodicity in periods
% (depending on the time series frequency); this option can be specified
% instead of `'Lambda='`; the smoothing parameter will be then determined
% based on the cut-off periodicity.
%
% * `'CutOffYear='` [ numeric | *empty* ] - Cut-off periodicity in years;
% this option can be specified instead of `'Lambda='`; the smoothing
% parameter will be then determined based on the cut-off periodicity.
%
% `'infoSet='` [ `1` | *`2`* ] - Information set assumption used in the
% filter: `1` runs a one-sided filter, `2` runs a two-sided filter.
%
% * `'Lambda='` [ numeric | *`@auto`* ] - Smoothing parameter;
% needs to be specified for tseries objects with indeterminate frequency.
% See Description for default values.
%
% * `'level='` [ tseries ] - Time series with soft and hard tunes on the
% level of the trend.
%
% * `'change='` [ tseries ] - Time series with soft and hard tunes on the
% change in the trend.
%
% * `'log='` [ `true` | *`false`* ] - Logarithmise the data before
% filtering, de-logarithmise afterwards.
%
% Description
% ============
%
% Default smoothing parameters
% ------------------------------
%
% If the user does not specify the smoothing parameter using the
% `'lambda='` option (or reassigns the default `@auto`), a default value is
% used. The default value is based on common practice and can be calculated
% using the date frequency of the input time series as $\lambda = (10 \cdot
% f)^n$, where $f$ is the frequency (yearly=1, half-yearly=2, quarterly=4,
% bi-monthly=6, monthly=12), and $n$ is the order of the filter, determined
% by the input parameter `Order`.
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

% BWF, HPF, LLF

%#ok<*VUNUS>
%#ok<*CTCH>

if ~isempty(varargin) && ~ischar(varargin{1})
    Range = varargin{1};
    varargin(1) = [];
else
    Range = Inf;
end

if isempty(Range)
    varargout{1} = empty(X);
    varargout{2} = empty(X);
    varargout{3} = NaN;
    varargout{4} = NaN;
    return
end

%--------------------------------------------------------------------------

[varargout{1:nargout}] = myfilter(X,Range,Order,varargin{:});

end
function This = moving(This,varargin)
% moving  Apply function to moving window of observations.
%
% Syntax
% =======
%
%     X = moving(X)
%     X = moving(X,Range,...)
%
% Input arguments
% ================
%
% * `X` [ tseries ] - Tseries object on whose observations the function
% will be applied.
%
% * `Range` [ numeric | Inf ] - Range on which the moving function will be
% applied; `Inf` means the entire range on which the time series is
% defined.
%
% Output arguments
% =================
%
% * `X` [ tseries ] - Output time series.
%
% Options
% ========
%
% * `'function='` [ function_handle | `@mean` ] - Function to be applied to a
% moving window of observations.
%
% * `'window='` [ numeric | *`Inf`* ] - The window of observations where 0
% means the current date, -1 means one period lag, etc. Inf means that the
% last n observations (including the current one) are used, where n is the
% frequency of the input data.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

if nargin == 1
    Range = Inf;
elseif isnumeric(varargin{1})
    Range = varargin{1};
    varargin(1) = [];
else
    Range = Inf;
end

opt = passvalopt('tseries.moving',varargin{:});

%--------------------------------------------------------------------------

if isequal(opt.window,Inf)
    freq = datfreq(This.start);
    if freq < 1
        opt.window = 0;
    else
        opt.window = -freq+1:0;
    end
end

if ~isequal(Range,Inf)
    This = resize(This,Range);
end

% @@@@@ MOSW
This = unop(@(varargin) tseries.mymoving(varargin{:}), ...
    This,0,opt.window,opt.function);

end

function varargout = get(This,varargin)
% get  Query tseries object property.
%
% Syntax
% =======
%
%     Ans = get(X,Query)
%     [Ans,Ans,...] = get(X,Query,Query,...)
%
% Input arguments
% ================
%
% * `X` [ model ] - Tseries object.
%
% * `Query` [ char ] - Query to the tseries object.
%
% Output arguments
% =================
%
% * `Ans` [ ... ] - Answer to the query.
%
% Valid queries to tseries objects
% =================================
%
% * `'end='` Returns [ numeric ] the date of the last observation.
%
% * `'freq='` Returns [ numeric ] the frequency (periodicity) of the time
% series.
%
% * `'nanEnd='` Returns [ numeric ] the last date at which observations are
% available in all columns; for scalar tseries, this query always returns
% the same as `'end'`.
%
% * `'nanRange='` Returns [ numeric ] the date range from `'nanstart'` to
% `'nanend'`; for scalar time series, this query always returns the same as
% `'range'`.
%
% * `'nanStart='` Returns [ numeric ] the first date at which observations are
% available in all columns; for scalar tseries, this query always returns
% the same as `'start'`.
%
% * `'range='` Returns [ numeric ] the date range from the first observation to the
% last observation.
%
% * `'start='` Returns [ numeric ] the date of the first observation.
%
% Description
% ============
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

P = inputParser();
if ismatlab
P.addRequired('X',@is.tseries);
P.addRequired('Query',@iscellstr);
P.parse(This,varargin);
else
P = P.addRequired('X',@(varargin)is.tseries(varargin{:}));
P = P.addRequired('Query',@iscellstr);
P = P.parse(This,varargin);
end

%--------------------------------------------------------------------------

[varargout{1:nargout}] = get@getsetobj(This,varargin{:});

end
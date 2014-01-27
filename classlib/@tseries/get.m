function varargout = get(This,varargin)
% get  Query tseries object property.
%
% Syntax
% =======
%
%     Value = get(x,Query)
%     [Value,Value,...] = get(x,Query,Query,...)
%
% Input arguments
% ================
%
% * `x` [ model ] - Tseries object.
%
% * `Query` [ char ] - Name of the queried property.
%
% Output arguments
% =================
%
% * `Value` [ ... ] - Value of the queried property.
%
% Valid queries on tseries objects
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
P.addRequired('x',@istseries);
P.addRequired('name',@iscellstr);
P.parse(This,varargin);

%--------------------------------------------------------------------------

varargout = cell(size(varargin));
varargin = strtrim(varargin);
n = length(varargin);
flag = true(1,n);
for iarg = 1 : n
    [varargout{iarg},flag(iarg)] = doGet(lower(varargin{iarg}));
end

% Report invalid queries.
if any(~flag)
    utils.error('model', ...
        'This is not a valid tseries object query: ''%s''.', ...
        varargin{~flag});
end

% Nested functions.

%**************************************************************************
    function [X,Flag] = doGet(Query)
        
        X = [];
        Flag = true;
        
        % Check for function calls inside the GET query.
        tokens = regexp(Query,'^([A-Za-z]\w*)\((.*?)\)$','tokens','once');
        transform = [];
        if ~isempty(tokens)
            Query = tokens{2};
            transform = str2func(tokens{1});
        end
        
        switch Query
            case {'range','first2last','start2end','first:last','start:end'}
                X = range(This);
            case {'min','minrange','nanrange'}
                sample = all(~isnan(This.data(:,:)),2);
                X = range(This);
                X = X(sample);
            case {'start','startdate','first'}
                X = This.start;
            case {'nanstart','nanstartdate','nanfirst','allstart','allstartdate'}
                sample = all(~isnan(This.data(:,:)),2);
                if isempty(sample)
                    X = NaN;
                else
                    X = This.start + find(sample,1,'first') - 1;
                end
            case {'end','enddate','last'}
                X = This.start + size(This.data,1) - 1;
            case {'nanend','nanenddate','nanlast','allend','allenddate'}
                sample = all(~isnan(This.data(:,:)),2);
                if isempty(sample)
                    X = NaN;
                else
                    X = This.start + find(sample,1,'last') - 1;
                end
            case {'freq','frequency','per','periodicity'}
                X = datfreq(This.start);
            case {'data','value','values'}
                % Not documented. Use x.data directly.
                X = This.data;
            case {'comment','comments'}
                % Not documented. User x.Comment directly.
                X = comment(This);
            otherwise
                Flag = false;
        end
        
        if Flag && ~isempty(transform)
            X = transform(X);
        end
        
    end % doGet().

end
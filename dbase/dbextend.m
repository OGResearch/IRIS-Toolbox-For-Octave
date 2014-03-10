function d = dbextend(d,varargin)
% dbextend  Combine tseries observations from two or more databases.
%
% Syntax
% =======
%
%     D = dbextend(D,D1,D2,...)
%
% Input arguments
% ================
%
% * `D` [ struct ] - Primary input database.
%
% * `D1`, `D2`, ... [ struct ] - Databases whose tseries observations will
% be used to extend or overwrite observations in the tseries objects of the
% same name in the primary database.
%
% Output arguments
% =================
%
% * `D` [ struct ] - Output database.
%
% Description
% ============
%
% If more than two databases are combined then they are processed
% one-by-one: the first is combined with the second, then the result is
% combined with the third, and so on, using the following rules:
%
% * If two non-empty tseries objects with the same frequency are combined,
% the observations are spliced together. If some of the observations
% overlap the observations from the second tseries are used.
% * If two empty tseries objects are combined the first is used.
% * If a non-empty tseries is combined with an empty tseries, the non-empty
% one is used.
% * If two objects are combined of which at least one is a non-tseries
% object, the second input object is used.
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

if ~isstruct(d) || any(~cellfun(@isstruct,varargin))
    utils.error('data', ...
        'All input arguments must be structs (databases).');
end

if length(varargin) > 1
    for i = 1 : length(varargin)
        d = dbextend(d,varargin{i});
    end
    return
end

%--------------------------------------------------------------------------

s = varargin{1};
dlist = fieldnames(d);
slist = fieldnames(s);
list = union(dlist,slist);
for j = 1 : numel(list)
    if ~isfield(s,list{j})
        continue
    end
    if ~isfield(d,list{j})
        d.(list{j}) = s.(list{j});
        continue
    end
    x = d.(list{j});
    y = s.(list{j});
    if is.tseries(x) && is.tseries(y)
        if get(x,'freq') == get(y,'freq')
            % Two non-empty tseries with the same frequency.
            d.(list{j}) = [x;y];
        elseif isempty(x.data)
            % Two empty tseries or the first non-empty and the
            % second empty; use the first input anyway.
            d.(list{j}) = y;
        elseif isempty(y.data)
            % Only the second tseries is non-empty.
            d.(list{j}) = x;
        else
            % Two non-empty tseries with different frequencies.
            d.(list{j}) = x;
        end
    else
        % At least one non-tseries input, use the second input.
        d.(list{j}) = y;
    end
end
templist = fieldnames(s);
templist = templist - list;
for j = 1 : length(templist)
    d.(templist{j}) = s.(templist{j});
end

end

function varargout = dbcol(This,varargin)
% dbcol  Retrieve the specified column or columns from database entries.
%
% Syntax
% =======
%
%     D = dbcol(D,K)
%
% Input arguments
% ================
%
% * `D` [ struct ] - Input database with (possibly) multivariate tseries
% objects and numeric arrays.
%
% * `K` [ numeric | logical | 'end' ] - Column or columns that will be
% retrieved from each tseries object or numeric array in in the intput
% database, `D`, and returned in the output database.
%
% Output arguments
% =================
%
% * `D` [ struct ] - Output database with tseries objects and numeric
% arrays reduced to the specified column.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

% Handle multiple input/output arguments.
if length(varargin) > 1
    varargout = cell(size(varargin));
    for i = 1 : length(varargin)
        varargout{i} = dbcol(This,varargin{i});
    end
    return
end

% Single input/output argument from here on.
inx = varargin{1};
list = fieldnames(This);
if isempty(list)
    varargout{1} = This;
    return
end

isEnd = isequal(inx,'end');

%--------------------------------------------------------------------------

for i = 1 : length(list)
    if is.tseries(This.(list{i}))
        try %#ok<TRYNC>
            if isEnd
                This.(list{i}) = This.(list{i}){:,end};
            else
                This.(list{i}) = This.(list{i}){:,inx};
            end
        end
    elseif isnumeric(This.(list{i})) ...
            || islogical(This.(list{i})) ...
            || iscell(This.(list{i}))
        try %#ok<TRYNC>
            if isEnd
                This.(list{i}) = This.(list{i})(:,end);
            else
                This.(list{i}) = This.(list{i})(:,inx);
            end
        end
    end
end
varargout{1} = This;

end
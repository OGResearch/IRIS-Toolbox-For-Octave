function varargout = dbcol(this,varargin)
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
        varargout{i} = dbcol(this,varargin{i});
    end
    return
end

% Single input/output argument from here on.
inx = varargin{1};
list = fieldnames(this);
if isempty(list)
    varargout{1} = this;
    return
end
if ischar(inx) && strcmp(inx,'end')
    inx = length(this.(list{1}));
end

%--------------------------------------------------------------------------

for i = 1 : length(list)
    if is.tseries(this.(list{i}))
        try %#ok<TRYNC>
            this.(list{i}) = this.(list{i}){:,inx};
        end
    elseif isnumeric(this.(list{i})) ...
            || islogical(this.(list{i})) ...
            || iscell(this.(list{i}))
        try %#ok<TRYNC>
            this.(list{i}) = this.(list{i})(:,inx);
        end
    end
end
varargout{1} = this;

end
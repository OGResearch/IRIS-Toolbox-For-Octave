function [x,varargout] = binop(fn,a,b,varargin)
% BINOP  [Not a public function] Binary operators and functions on tseries objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%**************************************************************************

if isa(a,'tseries') && isa(b,'tseries')
    asize = size(a.data);
    bsize = size(b.data);
    a.data = a.data(:,:);
    b.data = b.data(:,:);
    [anper,ancol] = size(a.data);
    [bnper,bncol] = size(b.data);
    if ancol == 1 && bncol ~= 1
        % First input argument is tseries scalar; second tseries with
        % multiple columns. Expand the first tseries to match the size of the
        % second in 2nd and higher dimensions.
        a.data = a.data(:,ones([1,bncol]));
        xsize = bsize;
    elseif ancol ~= 1 && bncol == 1
        % First tseries non-scalar; second tseries scalar.
        b.data = b.data(:,ones([1,ancol]));
        xsize = asize;
    else
        xsize = asize;
    end
    startdate = min([a.start,b.start]);
    enddate = max([a.start+anper-1,b.start+bnper-1]);
    range = startdate : enddate;
    adata = rangedata(a,range);
    bdata = rangedata(b,range);
    % Evaluate the operator.
    [xdata,varargout{1:nargout-1}] = fn(adata,bdata,varargin{:});    
    % Create the reu
    x = a;
    try
        x.data = reshape(xdata,[size(xdata,1),xsize(2:end)]);
    catch %#ok<CTCH>
        error('iris:tseries', ...
            ['The size of the resulting tseries object must match ', ...
            'the size of one of the input tseries objects.']);
    end
    x.start = range(1);
    x.Comment = cell([1,xsize(2:end)]);
    x.Comment(:) = {''};
    x = mytrim(x);
else
    bsize = size(b);
    asize = size(a);
    if isa(a,'tseries')
        x = a;
        a = a.data;
        if any(strcmp(char(fn),{'times','plus','minus','rdivide','mdivide','power'})) ...
                && bsize(1) == 1 && all(bsize(2:end) == asize(2:end))
            % Expand non-tseries data in first dimension to match the number
            % of periods of the tseries object for elementwise operators.
            b = b(ones([1,asize(1)]),:);
            b = reshape(b,asize);
        end
    else
        x = b;
        b = b.data;
        if any(strcmp(char(fn),{'times','plus','minus','rdivide','mdivide','power'})) ...
                && asize(1) == 1 && all(asize(2:end) == bsize(2:end))
            % Expand non-tseries data in first dimension to match the number
            % of periods of the tseries object for elementwise operators.
            a = a(ones([1,bsize(1)]),:);
            a = reshape(a,bsize);
        end
    end
    [tmp,varargout{1:nargout-1}] = fn(a,b,varargin{:});
    tmpsize = size(tmp);
    xsize = size(x.data);
    if tmpsize(1) == xsize(1)
        % Size of the numeric result in 1st dimension matches the size of the
        % input tseries object. Return a tseries object with the original
        % number of periods.
        x.data = tmp;
        if length(tmpsize) ~= length(xsize) ...
                || any(tmpsize(2:end) ~= xsize(2:end))
            x.Comment = cell([1,tmpsize(2:end)]);
            x.Comment(:) = {''};
        end
        x = mytrim(x);
    else
        % Size of the numeric result has changed in 1st dimension from the
        % size of the input tseries object. Return a numeric array.
        x = tmp;
    end
end

end

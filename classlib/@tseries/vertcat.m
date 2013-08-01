function x = vertcat(varargin)
% vertcat  Vertical concatenation of tseries objects.
%
% Syntax
% =======
%
%     X = [X1;X2;...;XN]
%     X = vertcat(X1,X2,...,XN)
%
% Input arguments
% ================
%
% * `X1`, ..., `XN` [ tseries ] - Input tseries objects that will be
% vertically concatenated; they all have to have the same size in 2nd and
% higher dimensions.
%
% Output arguments
% =================
%
% * `X` [ tseries ] - Output tseries object created by overlaying `X1` with
% `X2`, and so on, see description below.
%
% Description
% ============
%
% Any NaN observations in `X1` are replaced with the observations from
% `X2`. This replacement is performed separately for the real and imaginary
% parts of the input data, and the real and imaginary parts are combined
% back again.
%
% The input tseries objects must be consistent in 2nd and higher
% dimensions. The only exception is if some of the tseries objects are
% scalar time series (i.e. with one column only) while the rest of them are
% not. In that case, the scalar tseries are automatically expanded to match
% the size of the multivariate tseries.
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%**************************************************************************

if length(varargin) == 1
    x = varargin{1};
    return
end

% Check classes and frequencies.
[inputs,ixtseries] = catcheck(varargin{:});
if any(~ixtseries)
    error('iris:tseries', ...
        ['Cannot vertically overly tseries objects ', ...
        'with non-tseries objects.']);
end

ninput = length(inputs);
x = inputs{1};
xsize = size(x.data);
x.data = x.data(:,:);

for i = 2 : ninput
    y = inputs{i};
    ysize = size(y.data);
    y.data = y.data(:,:);
    xsize2 = size(x.data,2);
    ysize2 = size(y.data,2);
    if xsize2 ~= ysize2
        if xsize2 == 1
            x.data = x.data(:,ones(1,ysize2));
            xsize = ysize;
        elseif ysize2 == 1
            y.data = y.data(:,ones(1,xsize2));
            y.Comment = y.Comment(1,ones(1,xsize2));
        else
            utils.error('tseries', ...
                ['Vertically overlayed tseries objects', ...
                'must be consistent in 2nd and higher dimensions.']);
        end
    end
    
    % Determine the longest stretch range necessary.
    startdate = min([x.start,y.start]);
    enddate = max([x.start+size(x.data,1)-1,y.start+size(y.data,1)-1]);    
    range = startdate : enddate;
    
    % Get continuous data from both series on the largest stretch range.
    xdata = rangedata(x,range);
    ydata = rangedata(y,range);
    
    % Identify and overlay NaNs separately in the real and imaginary parts of
    % the data.
    xdatareal = real(xdata);
    ydatareal = real(ydata);
    xdataimag = imag(xdata);
    ydataimag = imag(ydata);
    indexreal = ~isnan(ydatareal);
    indeximag = ~isnan(ydataimag);
    xdatareal(indexreal) = ydatareal(indexreal);
    xdataimag(indeximag) = ydataimag(indeximag);

    % Combine the real and imaginary parts of the data again.
    x.data = xdatareal + 1i*xdataimag;
    
    % Reset the start date.
    x.start = startdate;
end

if length(xsize) > 2
    x.data = reshape(x.data,[size(x.data,1),xsize(2:end)]);
end
x.Comment = y.Comment;

if ~isempty(x.data) && any(any(isnan(x.data([1,end],:))))
    x = mytrim(x);
end

end

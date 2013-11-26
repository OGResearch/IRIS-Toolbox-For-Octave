function [Y,Range] = rangedata(X,Range)
% rangedata  Retrieve tseries data on a continuous range.
%
% Syntax
% =======
%
%     [Y,Range] = rangedata(X,Range)
%     [Y,Range] = rangedata(X,[StartDate,EndDate])
%
% Input arguments
% ================
%
% * `X` [ tseries ] - Tseries object.
%
% * `Range` [ numeric ] - A continuous date range; data from Range(1) to
% Range(end) will be returned.
%
% * `StartDate` [ numeric ] - Start date of the range.
%
% * `EndDate` [ numeric ] - End date of the range.
%
% Output arguments
% =================
%
% * `Y` [ numeric ] - Output data.
%
% * `Range` [ numeric ] - The actual entire date range from which the data
% come.
%
% Description
% ============
%
% The `rangedata` function is equivalent to calling
%
%     y = x(range(1):range(end));
%
% but it designed to be more efficient for the special case of contiunous
% date ranges.
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

if nargin == 1
    Y = X.data;
    Range = [X.start,X.start+size(X.data,1)-1];
    return
end

tmpSize = size(X.data);
if isempty(Range) || isequalwithequalnans(Range,NaN)
    Y = zeros([0,tmpSize(2:end)]);
    return
end

if isnan(X.start) || isempty(X.data)
    Y = nan([round(Range(end)-Range(1)+1),tmpSize(2:end)]);
    return
end

nCol = prod(tmpSize(2:end));

[~,~,f]=dat2ypf(Range) ;
if any( f~=X.freq ) && ~any(isinf(Range))
    utils.error('tseries:rangedata',...
        'Data frequency and range frequency mismatch.') ;
end

if isinf(Range(1))
    % Range is Inf or [-Inf,...].
    startInx = 1;
else
    startInx = round(Range(1) - X.start + 1);
end

if isinf(Range(end))
    % Range is Inf or [...,Inf].
    endInx = tmpSize(1);
else
    endInx = round(Range(end) - X.start + 1);
end

if startInx > endInx
    Y = nan(0,nCol);
elseif startInx >= 1 && endInx <= tmpSize(1)
    Y = X.data(startInx:endInx,:);
elseif (startInx < 1 && endInx < 1) ...
        || (startInx > tmpSize(1) && endInx > tmpSize(1))
    Y = nan(endInx-startInx+1,nCol);
elseif startInx >= 1
    Y = [X.data(startInx:end,:); ...
        nan(endInx-tmpSize(1),nCol)];
elseif endInx <= tmpSize(1)
    Y = [nan(1-startInx,nCol); ...
        X.data(1:endInx,:)];
else
    Y = [nan(1-startInx,nCol); ...
        X.data(:,:);nan(endInx-tmpSize(1),nCol)];
end

if length(tmpSize) > 2
    Y = reshape(Y,[size(Y,1),tmpSize(2:end)]);
end

% Return actual range if requested.
if nargout > 1
    Range = X.start + (startInx : endInx) - 1;
end

end

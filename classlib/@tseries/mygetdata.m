function [Data,Dates,This] = mygetdata(This,Dates,varargin)
% mygetdata  [Not a public function] Get time series data for specific (discontinuous) dates.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

% References to 2nd and higher dimensions.
if ~isempty(varargin)
    This.data = This.data(:,varargin{:});
    if nargout > 2
        This.Comment = This.Comment(1,varargin{:});
    end
end

% References to time dimension.
xSize = size(This.data);
This.data = This.data(:,:);
remove = true(1,xSize(1));
if isnumeric(Dates) && ~isequal(Dates,Inf)
    Dates = Dates(:);
    Data = nan([length(Dates),xSize(2:end)]);
    if ~isempty(This.data)
        index = round(Dates - This.start + 1);
        test = index >= 1 ...
            & index <= xSize(1) ...
            & freqcmp(This.start,Dates);
        Data(test,:) = This.data(index(test),:);
        if nargout > 2
            remove(index(test)) = false;
        end
    end
elseif isequal(Dates,Inf) || isequal(Dates,':') || isequal(Dates,'max')
    Dates = This.start + (0 : xSize(1)-1);
    Data = This.data;
    if nargout > 2
        remove(:) = false;
    end
elseif isequal(Dates,'min')
    Dates = This.start + (0 : xSize(1)-1);
    sample = all(~isnan(This.data),2);
    Data = This.data(sample,:);
    if nargout > 2
        remove(sample) = false;
    end
else
    Data = This.data([],:);
end

Data = reshape(Data,[size(Data,1),xSize(2:end)]);

if nargout > 2
    if isreal(This.data)
        This.data(remove,:) = NaN;
    else
        This.data(remove,:) = NaN+1i*NaN;
    end
    This.data = reshape(This.data,[size(This.data,1),xSize(2:end)]);
end

end
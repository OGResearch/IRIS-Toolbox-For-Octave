function X = cat(N,varargin)
% cat  Tseries object concatenation along n-th dimension.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

if length(varargin) == 1
    % Matlab calls horzcat(x) first for [x;y].
    X = varargin{1};
    return
end

% Check classes and frequencies.
[inputs,ixTseries] = catcheck(varargin{:});

% Remove inputs with zero size in all higher dimensions.
% Remove empty numeric arrays.
remove = false(size(inputs));
for i = 1 : length(inputs)
    si = size(inputs{i});
    if all(si(2:end) == 0), remove(i) = true;
    elseif isnumeric(inputs{i}) && isempty(inputs{i}), remove(i) = true;
    end
end
inputs(remove) = [];
ixTseries(remove) = [];

if isempty(inputs)
    X = tseries([],[]);
    return
end

nInput = length(inputs);
% Find earliest startdate and latest enddate.
start = nan(1,nInput);
finish = nan(1,nInput);
for i = find(ixTseries)
    start(i) = inputs{i}.start;
    finish(i) = start(i) + size(inputs{i}.data,1) - 1;
end

% Find startdates and enddates.
minStart = min(start(~isnan(start)));
maxFinish = max(finish(~isnan(finish)));
start(~ixTseries) = -Inf;
finish(~ixTseries) = Inf;

% Expand data with pre- or post-sample NaNs.
if ~isempty(minStart)
    for i = find(start > minStart | finish < maxFinish)
        dim = size(inputs{i}.data);
        if isnan(inputs{i}.start)
            inputs{i}.data = nan([round(maxFinish-minStart+1),dim(2:end)]);
        else
            inputs{i}.data = [nan([round(start(i)-minStart),dim(2:end)]);inputs{i}.data;nan([round(maxFinish-finish(i)),dim(2:end)])];
        end
    end
    for i = find(isnan(start))
        dim = size(inputs{i}.data);
        inputs{i}.data = nan([maxFinish-minStart+1,dim(2:end)]);
    end
    nPer = round(maxFinish - minStart + 1);
else
    nPer = 0;
end

% Struct for resulting tseries.
X = tseries();
if ~isempty(minStart)
    X.start = minStart;
else
    X.start = NaN;
end

% Concatenate individual inputs.
empty = true;
for i = 1 : nInput
    if ixTseries(i)
        if empty
            X.data = inputs{i}.data;
            X.Comment = inputs{i}.Comment;
            empty = false;
        else
            X.data = cat(N,X.data,inputs{i}.data);
            X.Comment = cat(N,X.Comment,inputs{i}.Comment);
        end
    else
        data = inputs{i};
        si = size(data);
        data = data(:,:);
        if si(1) > 1 && si(1) < nPer
            data(end+1:nPer,:) = NaN;
        elseif si(1) > 1 && si(1) > nPer
            data = data(:,:);
            data(nPer+1:end,:) = [];
        elseif si(1) == 1 && nPer > 1
            data = data(:,:);
            data = data(ones(1,nPer),:);
        end
        data = reshape(data,[nPer,si(2:end)]);
        comment = cell([1,si(2:end)]);
        comment(:) = {''};
        if empty
            X.data = data;
            X.Comment = comment;
            empty = false;
        else
            X.data = cat(N,X.data,data);
            X.Comment = cat(N,X.Comment,comment);
        end
    end
end

end
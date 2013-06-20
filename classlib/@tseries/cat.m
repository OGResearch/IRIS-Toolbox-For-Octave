function X = cat(N,varargin)
% cat  [Not a publich function] Tseries object concatenation along n-th dimension.
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
[inputs,isTseries] = catcheck(varargin{:});

% Remove inputs with zero size in all higher dimensions.
% Remove empty numeric arrays.
remove = false(size(inputs));
for i = 1 : length(inputs)
    iDataSize = size(inputs{i});
    if all(iDataSize(2:end) == 0), remove(i) = true;
    elseif isnumeric(inputs{i}) && isempty(inputs{i}), remove(i) = true;
    end
end
inputs(remove) = [];
isTseries(remove) = [];

if isempty(inputs)
    X = tseries([],[]);
    return
end

nInp = length(inputs);
% Find earliest startdate and latest enddate.
start = nan(1,nInp);
finish = nan(1,nInp);
for i = find(isTseries)
    start(i) = inputs{i}.start;
    finish(i) = start(i) + size(inputs{i}.data,1) - 1;
end

% Find startdates and enddates.
minStart = min(start(~isnan(start)));
maxFinish = max(finish(~isnan(finish)));
start(~isTseries) = -Inf;
finish(~isTseries) = Inf;

% Expand data with pre- or post-sample NaNs.
if ~isempty(minStart)
    for i = find(start > minStart | finish < maxFinish)
        dim = size(inputs{i}.data);
        if isnan(inputs{i}.start)
            % Empty tseries object.
            inputs{i}.data = nan([round(maxFinish-minStart+1),dim(2:end)]);
        else
            % Non-empty tseries object.
            nPre = round(start(i)-minStart);
            nPost = round(maxFinish-finish(i));
            inputs{i}.data = [ ...
                nan([nPre,dim(2:end)]); ...
                inputs{i}.data; ...
                nan([nPost,dim(2:end)]); ...
                ];
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
for i = 1 : nInp
    if isTseries(i)
        if empty
            X.data = inputs{i}.data;
            X.Comment = inputs{i}.Comment;
            empty = false;
        else
            X.data = cat(N,X.data,inputs{i}.data);
            X.Comment = cat(N,X.Comment,inputs{i}.Comment);
        end
    else
        iData = inputs{i};
        iDataSize = size(iData);
        iData = iData(:,:);
        if iDataSize(1) > 1 && iDataSize(1) < nPer
            iData(end+1:nPer,:) = NaN;
        elseif iDataSize(1) > 1 && iDataSize(1) > nPer
            iData = iData(:,:);
            iData(nPer+1:end,:) = [];
        elseif iDataSize(1) == 1 && nPer > 1
            iData = iData(:,:);
            iData = iData(ones(1,nPer),:);
        end
        iData = reshape(iData,[nPer,iDataSize(2:end)]);
        comment = cell([1,iDataSize(2:end)]);
        comment(:) = {''};
        if empty
            X.data = iData;
            X.Comment = comment;
            empty = false;
        else
            X.data = cat(N,X.data,iData);
            X.Comment = cat(N,X.Comment,comment);
        end
    end
end

end
function [H,Colors] = mybarcon(Ax,X,Y,varargin)
% mybarcon  [Not a public function] Contribution bar graph .
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

if isempty(X) || isempty(Y)
    H = [];
    Colors = [];
    return
end

opt = passvalopt('tseries.barcon',varargin{:});

if isempty(opt.colormap)
    opt.colormap = get(gcf(),'colorMap');
end

%--------------------------------------------------------------------------

[nPer,nData] = size(Y);
nc = size(opt.colormap,1);

% Make sure we never run short of colors.
while nData > nc
    opt.colormap = [opt.colormap;opt.colormap];
    nc = size(opt.colormap,1);
end
if opt.evenlyspread
    % Colors are evenly spread across the color map.
    colorindex = 1 + round(0 : (nc-1)/(nData-1) : nc-1);
else
    % Colors are taken in order of appearance in the color map.
    colorindex = 1 : nData;
end
Colors = opt.colormap(colorindex,:);    

% Remember the `nextPlot` status.
nextPlot = get(Ax,'nextPlot');

% Width of bars.
if length(X) > 1
    avgXStep = mean(diff(X));
else
    avgXStep = 1;
end
d = avgXStep*opt.barwidth/2;

H = nan(nPer,nData);
yy = nan(4,nPer,nData);
xx = nan(4,nPer);

if isnumeric(opt.ordering)
    opt.ordering = opt.ordering(:).';
elseif strcmpi(opt.ordering,'preserve')
    opt.ordering = 1 : nData;
end

for i = 1 : nPer
    if all(isnan(Y(i,:)))
        continue
    end
    if isnumeric(opt.ordering)
        % User-spec ordering of same-sign contributions.
        sortInx = opt.ordering;
        ySort = Y(i,sortInx);
        isNegative = ySort < 0;
        ySort = [ ...
            sum(ySort(isNegative)); ...
            -fliplr(ySort(isNegative)).'; ...
            ySort(~isNegative).'; ...
        ];
        sortInx = ...
            [fliplr(sortInx(isNegative)),sortInx(~isNegative)];
    elseif ischar(opt.ordering)
        % Use `sort` with 'ascend' or 'descend'.
        [ySort,sortInx] = sort(Y(i,:),2,opt.ordering);
        isNegative = ySort < 0;
        ySort = [ ...
            sum(ySort(isNegative)); ...
            -ySort(isNegative).'; ...
            ySort(~isNegative).'; ...
        ];
        sortInx = [sortInx(isNegative),sortInx(~isNegative)];
    end
    cySort = cumsum(ySort,1);
    % Stow y-coordinates for each series and all periods so that we can
    % run `fill` on all periods at once.
    for j = 1 : nData
        pos = find(sortInx == j);
        yy(:,i,j) = cySort([pos,pos,pos+1,pos+1],1);
    end
    xx(:,i) = X(i)+[-1;1;1;-1]*d;
end

% Plot bars for one series and all periods at once.
for j = 1 : nData
    if j == 2
        set(Ax,'nextPlot','add');
    end
    H(:,j) = fill(xx,yy(:,:,j),Colors(j,:));
end

% Make all bar clusters invisible except the first one.
grfun.excludefromlegend(H(2:end,:));

% Reset `nextPlot` to its original status.
set(Ax,'nextPlot',nextPlot);

end
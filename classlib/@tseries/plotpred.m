function [H1,H2,H3,Range,Data,Grid] = plotpred(varargin)
% plotpred  Plot Kalman filter predictions.
%
% Syntax
% =======
%
%     [H1,H2,H3] = plotpred(X,Y,...)
%     [H1,H2,H3] = plotpred(Ax,X,Y,...)
%     [H1,H2,H3] = plotpred(Ax,Range,X,Y,...)
%
% Input arguments
% ================
%
% * `X` [ tseries ] - Input data with time series observations.
%
% * `Y` [ tseries ] - Input data with predictions calculated in a Kalman
% filter run with an `'ahead='` option.
%
% * `Ax` [ numeric ] - Handle to axes object in which the data will be
% plotted.
%
% * `Range` [ numeric | Inf ] - Date range on which the input data will be
% plotted.
%
% Output arguments
% =================
%
% * `H1` [ numeric ] - Handles to a line object showing the time series
% observations (the first column, `X`, in the input data).
%
% * `H2` [ numeric ] - Handles to line objects showing the Kalman filter
% predictions (the second and further columns, `Y`, in the input data).
%
% * `H3` [ numeric ] - Handles to one-point line objects displaying a
% marker at the start of each line.
%
% Options
% ========
%
% * `'connect='` [ *`true`* | `false` ] - Connect the prediction lines,
% `Y`,  with the corresponding observation in `X`.
%
% * `'firstMarker='` [ *`'none'`* | char ] - Type of marker displayed at
% the start of each prediction line.
%
% * `'showNaNLines='` [ *`true`* | `false` ] - Show or remove lines with
% whose starting points are NaN (missing observations).
%
% See help on [`plot`](tseries/plot) and on the built-in function
% `plot` for options available.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

if isempty(varargin)
    return
end

% Handle to axes object.
if isnumericscalar(varargin{1}) && ishandle(varargin{1})
    ax = varargin{1};
    varargin(1) = [];
else
    ax = get(gcf(),'currentAxes');
    if isempty(ax);
        ax = axes('box','on');
    end
end

% Range.
if isnumeric(varargin{1})
    Range = varargin{1};
    varargin(1) = [];
else
    Range = Inf;
end

% Input data.
x1 = varargin{1};
varargin(1) = [];
if ~isempty(varargin) && isa(varargin{1},'tseries')
    % Syntax with two separate tseries, plotpred(X,Y).
    x2 = varargin{1};
    varargin(1) = [];
else
    % Syntax with one combined tseries, plotpred([X,Y]).
    x2 = x1;
    x2.data = x2.data(:,2:end);
    x1.data = x1.data(:,1);
end

[opt,varargin] = passvalopt('tseries.plotpred',varargin);

%--------------------------------------------------------------------------

if ~isempty(x1)
    f1 = datfreq(x1.start);
    f2 = datfreq(x2.start);
    if f1 ~= f2
        utils.error('tseries', ...
            'Input data must have the same date frequency.');
    end
    [Data,fullRange] = rangedata([x1,x2]);
else
    nPer = size(x2.data,1);
    x1 = x2;
    x1.data = nan(nPer,1);
    x1.Comment = {''};
    [Data,fullRange] = rangedata(x2);
end


if opt.connect
    diagPos = 0;
else
    diagPos = -1;
    Data(:,1) = NaN;
end

nPer = size(Data,1);
ahead = size(Data,2);
Data = [Data;nan(ahead-1,ahead)];

% Re-arrange the prediction matrix.
data2 = nan(nPer+ahead-1,nPer);
for t = 1 : nPer
    row = t+(0:ahead-1);
    data2(row,t,:) = diag(Data(t+(0:ahead-1),:));
end
data2 = data2(1:nPer,:);

% Remove lines with missing starting point.
if ~opt.shownanlines
    diagNaN = isnan(diag(data2,diagPos));
    data2(:,diagNaN) = NaN;
end

% Find first data point in each column of the prediction matrix.
startPoint = nan(nPer+ahead-1,nPer);
for iCol = 1 : size(data2,2)
    pos = find(~isnan(data2(:,iCol)),1);
    if ~isempty(pos)
        startPoint(pos,iCol) = data2(pos,iCol);
    end
end
startPoint = replace(x2,startPoint(1:nPer,:),fullRange(1));

x2 = replace(x2,data2,fullRange(1));

% Determine the plot range.
doPlotRange();

% Store current `hold` settings.
fig = get(ax,'parent');
figNextPlot = get(fig,'nextPlot');
axNextPlot = get(ax,'nextPlot');
appPlotHoldStyle = getappdata(ax,'PlotHoldStyle');

% Hold all.
set(fig,'NextPlot','add');
set(ax,'NextPlot','add');
setappdata(ax,'PlotHoldStyle',true);

% Plot the actual data.
[H1,~,data1] = plot(ax,Range,x1,varargin{:},opt.firstline{:});

% Plot the predictions.
[H2,~,data2,Grid] = plot(ax,Range,x2,varargin{:},opt.predlines{:});
set(H2,'tag','plotpred');

% Plot start points.
H2color = get(H2,'color');
H3 = plot(ax,Range,startPoint);
set(H3,{'color'},H2color,'marker',opt.firstmarker);

% Restore hold settings.
set(fig,'NextPlot',figNextPlot);
set(ax,'NextPlot',axNextPlot);
setappdata(ax,'PlotHoldStyle',appPlotHoldStyle);

if ~isempty(H1) && ~isempty(H2) ...
        && ~any(strcmpi(varargin(1:2:end),'linestyle')) ...
        && ~any(strcmpi(opt.predlines(1:2:end),'linestyle'))
    set(H2,'linestyle','--');
end

Data = [data1,data2];

% Nested functions.

%**************************************************************************
    function doPlotRange()
        Range = [Range(1),Range(end)];
        if ~isfinite(Range(1))
            Range(1) = fullRange(1);
        end
        if ~isfinite(Range(end))
            Range(end) = fullRange(end);
        end
        Range = Range(1) : Range(end);
    end % doPlotRange().

end
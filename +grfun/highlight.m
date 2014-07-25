function [Pp,Cp] = highlight(varargin)
% highlight  Highlight specified range or date range in a graph.
%
% Syntax
% =======
%
%     [Pt,Cp] = highlight(Range,...)
%     [Pt,Cp] = highlight(Ax,Range,...)
%
% Input arguments
% ================
%
% * `Range` [ numeric ] - X-axis range or date range that will be
% highlighted.
%
% * `Ax` [ numeric ] - Handle(s) to axes object(s) in which the highlight
% will be made.
%
% Output arguments
% =================
%
% * `Pt` [ numeric ] - Handle to the highlighted area (patch object).
%
% * `Cp` [ numeric ] - Handle to the caption (text object).
%
% Options
% ========
%
% * `'caption='` [ char ] - Annotate the highlighted area with a text
% string.
%
% * `'color='` [ numeric | *`0.8`* ] - An RGB color code, a Matlab color
% name, or a scalar shade of gray.
%
% * `'excludeFromLegend='` [ *`true`* | `false` ] - Exclude the highlighted
% area from legend.
%
% * `'hPosition='` [ 'center' | 'left' | *'right'* ] - Horizontal position
% of the caption.
%
% * `'vPosition='` [ 'bottom' | 'middle' | *'top'* | numeric ] - Vertical
% position of the caption.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%#ok<*AGROW>

if ~isempty(varargin{1}) && all(ishghandle(varargin{1}))
    Ax = varargin{1};
    varargin(1) = [];
else
    Ax = gca();
end

range = varargin{1};
varargin(1) = [];

Pp = []; % Handles to patch objects.
Cp = []; % Handles to caption objects.

if isempty(range)
    return
end

% Multiple separate ranges.
if iscell(range)
    for i = 1 : numel(range)
        [pt,c] = highlight(Ax,range{i},varargin{:});
        Pp = [Pp,pt(:).'];
        Cp = [Cp,c(:).'];
    end
    return
end

opt = passvalopt('grfun.highlight',varargin{:});

if isnumericscalar(opt.color)
    opt.color = opt.color*[1,1,1];
end

%--------------------------------------------------------------------------

if false % ##### MOSW
    infLim = 1e10;
else
    infLim = 1e5; %#ok<UNRCH>
end

zPos = -2;

for iAx = Ax(:).'
    % Preserve the order of figure children.
    % fg = get(iAx,'parent');
    % fgch = get(fg,'children');
    
    % Check for plotyy peers, and return the background axes object.
    h = grfun.mychkforpeers(iAx);
    
    % Move grid to the foreground; otherwise, the upper edge of the plot box
    % will be overpainted by the highlight patch.
    set(h,'layer','top');
    
    % NB: Instead of moving the grid to the foreground, we could use
    % transparent color for the highligh object (faceAlpha). This is
    % unfortunately not supported by the Painters renderer.
    
    range = range([1,end]);
    around = opt.around;
    if isequal(getappdata(h,'tseries'),true)
        freq = datfreq(range(1));
        timeScale = dat2dec(range,'centre');
        if isempty(timeScale)
            continue
        end
        if isnan(around)
            around = 0.5 / max(1,freq);
        end
        timeScale = [timeScale(1)-around,timeScale(end)+around];
    else
        if isnan(around)
            around = 0.5;
        end
        timeScale = [range(1)-around,range(end)+around];
    end
    
    if false % ##### MOSW
        bounds = objbounds(iAx);
    else
        bounds = [0,0,0,0]; %#ok<UNRCH>
    end
    xData = timeScale([1,2,2,1]);
    yData = infLim*[-1,-1,1,1] + bounds([3,3,4,4]);
    zData = zPos*ones(size(xData));
    pt = patch(xData,yData,zData,opt.color, ...
       'parent',h,'edgeColor','none','faceAlpha',1-opt.transparent, ...
       'yLimInclude','off');
    
    % Add caption to the highlight.
    if ~isempty(opt.caption)
        c = grfun.mycaption(h,timeScale([1,end]), ...
            opt.caption,opt.vposition,opt.hposition);
        Cp = [Cp,c];
    end
    
    % Make sure zLim includes zPos.
    zLim = get(iAx,'zLim');
    zLim(1) = min(zLim(1),zPos);
    zLim(2) = max(zLim(2),0);
    set(iAx,'zLim',zLim);
    
    Pp = [Pp,pt];
end

% Tag the highlights and captions for `qstyle`.
set(Pp,'tag','highlight');
set(Cp,'tag','highlight-caption');

if isempty(Pp)
    return
end

if false % ##### MOSW
    if opt.excludefromlegend
        % Exclude highlighted area from legend.
        grfun.excludefromlegend(Pp);
    end
else
    % Do nothing.
end

end

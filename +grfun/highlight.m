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
% * `'caption='` [ char ] - Annotate the highlighted area with this text
% string.
%
% * `'color='` [ numeric | *`0.8`* ] - An RGB color code, a Matlab
% color name, or a scalar shade of gray.
%
% * `'excludeFromLegend='` [ *`true`* | `false` ] - Exclude the highlighted area
% from legend.
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

if all(ishghandle(varargin{1}))
    Ax = varargin{1};
    varargin(1) = [];
else
    Ax = gca();
end

range = varargin{1};
varargin(1) = [];

Pp = []; % Handles to patch objects.
Cp = []; % Handles to caption objects.

% Multiple separate ranges.
if iscell(range)
    for i = 1 : numel(range)
        [pt,cp] = highlight(Ax,range{i},varargin{:});
        Pp = [Pp,pt(:).'];
        Cp = [Cp,cp(:).'];
    end
    return
end

opt = passvalopt('grfun.highlight',varargin{:});

if is.numericscalar(opt.color)
    opt.color = opt.color*[1,1,1];
end

%--------------------------------------------------------------------------

for iAx = Ax(:).'
    % Preserve the order of figure children.
    fg = get(iAx,'parent');
    
    % Temporary show excluded from legend (for Octave's way of excluding)
    if ~ismatlab
        grfun.mytrigexcludedfromlegend(fg,'on');
    end
    
    fgch = get(fg,'children');
    
    % Check for plotyy peers, and return the background axes object.
    h = grfun.mychkforpeers(iAx);
    
    % Move grid to the foreground for the grid to be visible.
    set(h,'layer','top');
    
    % Change grid style in HG2 back to black dotted line for the grid lines
    % not to interfere so much with the plotted data.
    if is.hg2()
        set(h,'gridLineStyle',':', ...
            'gridColor',0.7*[1,1,1]);
    end
    
    % NOTE: Instead of moving the grid to the foreground, we could use
    % transparent color for the highligh object (faceAlpha). This is
    % however not supported by the Painters renderer.
    
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
    
    if ismatlab
        yData = realmax*[-1,-1,1,1]; % such a limits causes OpenGL tesselation error in Octave
    else
        yLim = get(h,'ylim');
        yData = yLim([1,1,2,2]);
    end
    xData = timeScale([1,2,2,1]);
    pt = patch(xData,yData,opt.color, ...
       'parent',h,'edgeColor','none','faceAlpha',1-opt.transparent, ...
       'yLimInclude','off');
    
    % Add caption to the highlight.
    cp = [];
    if ~isempty(opt.caption)
        cp = grfun.mycaption(h,timeScale([1,end]), ...
            opt.caption,opt.vposition,opt.hposition);
    end
    
    % Move the highlight patch object to the background.
    ch = get(h,'children');
    ch(ch == pt) = [];
    ch(end+1) = pt;
    set(h,'children',ch);
    
    if ~ismatlab % keep old behaviour for Octave
        % Update y-data whenever the parent y-lims change.
        grfun.listener(h,pt,'highlight');
    end
    
    % Reset the order of figure children.
    set(fg,'children',fgch);
    
    % Hide back excluded from legend (for Octave's way of excluding)
    if ~ismatlab
        grfun.mytrigexcludedfromlegend(fg,'off');
    end
    
    Pp = [Pp,pt];
    Cp = [Cp,cp];
end

% Tag the highlights and captions for `qstyle`.
set(Pp,'tag','highlight');
set(Cp,'tag','highlight-caption');

if isempty(Pp)
    return
end

if opt.excludefromlegend
    % Exclude highlighted area from legend.
    grfun.excludefromlegend(Pp);
end

end
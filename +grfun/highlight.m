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
% * `'color='` [ numeric | *[0.9,0.9,0.9]* ] - An RGB color code or a Matlab
% color name.
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
% -Copyright (c) 2007-2013 IRIS Solutions Team.

if all(ishghandle(varargin{1}))
    Ax = varargin{1};
    varargin(1) = [];
else
    Ax = gca();
end

range = varargin{1};
varargin(1) = [];

if iscell(range)
    Pp = [];
    Cp = [];
    for i = 1 : numel(range)
        [pt,cp] = highlight(Ax,range{i},varargin{:});
        Pp = [Pp,pt(:).'];
        Cp = [Cp,cp(:).'];
    end
    return
end

opt = passvalopt('grfun.highlight',varargin{:});

if ~isempty(opt.color)
    opt.colour = opt.color;
end

if ~isempty(opt.grade)
    opt.colour = opt.grade*[1,1,1];
end

%--------------------------------------------------------------------------

Pp = [];
Cp = [];

for iAx = Ax(:).'
    % Preserve the order of figure children.
    fg = get(iAx,'parent');
    fgch = get(fg,'children');
    
    % Check for plotyy peers, and return the background axes object.
    h = grfun.mychkforpeers(iAx);
    
    % Make axes sit on top of lines and patches so that grid is visible.
    set(h,'layer','top');
    
    range = range([1,end]);
    if isequal(getappdata(h,'tseries'),true)
        freq = datfreq(range(1));
        timeScale = dat2dec(range,'centre');
        if isempty(timeScale)
            continue
        end
        if freq > 0
            around = 1/(2*freq);
        else
            around = 0.5;
        end
        timeScale = [timeScale(1)-around,timeScale(end)+around];
    else
        timeScale = [range(1)-opt.around,range(end)+opt.around];
    end

    yLim = get(h,'ylim');
    yData = yLim([1,1,2,2]);
    xData = timeScale([1,2,2,1]);
    pt = patch(xData,yData,opt.colour, ...
        'parent',h,'edgeColor','none');

    % Add caption to the highlight.
    if ~isempty(opt.caption)
        cp = grfun.mycaption(h,timeScale([1,end]), ...
            opt.caption,opt.vposition,opt.hposition);
        Cp = [Cp,cp];
    end

    % Move the highlight patch object to the background.
    ch = get(h,'children');
    ch(ch == pt) = [];
    ch(end+1) = pt;
    set(h,'children',ch);

    % Update y-data whenever the parent y-lims change.
    grfun.listener(h,pt,'highlight');

    % Reset the order of figure children.
    set(fg,'children',fgch);
    Pp = [Pp,pt]; %#ok<*AGROW>

end

% Tag the highlights and captions for `qstyle`.
set(Pp,'tag','highlight');
set(Cp,'tag','highlight-caption');

if ~isempty(Pp) && opt.excludefromlegend
    % Exclude highlighted area from legend.
    grfun.excludefromlegend(Pp);
end

end
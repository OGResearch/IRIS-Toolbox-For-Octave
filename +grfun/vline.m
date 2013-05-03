function [Ln,Cp] = vline(varargin)
% vline  Add vertical line with text caption at the specified position.
%
% Syntax
% =======
%
%     [Ln,Cp] = grfun.vline(Xpos,...)
%     [Ln,Cp] = grfun.vline(H,XPos,...)
%
% Input arguments
% ================
%
% * `'XPos`' [ numeric ] - Horizontal position or vector of positions at
% which the vertical line or lines will be drawn.
%
% * `H` [ numeric ] - Handle to an axes object (graph) or to a figure
% window in which the the line will be added; if not specified the line
% will be added to the current axes.
%
% Output arguments
% =================
%
% * `Ln` [ numeric ] - Handle to the vline(s) plotted (line objects).
%
% * `Cp` [ numeric ] - Handle to the caption(s) created (text objects).
%
% Options
% ========
%
% * `'caption='` [ char ] - Annotate the vline with this text string.
%
% * `'excludeFromLegend='` [ *`true`* | `false` ] - Exclude the line from
% legend.
%
% * `'hPosition='` [ `'center'` | `'left'` | *`'right'`* ] - Horizontal
% position of the caption.
%
% * `'vPosition='` [ `'bottom'` | `'middle'` | *`'top'`* | numeric ] -
% Vertical position of the caption.
%
% * `'timePosition='` [ `'after'` | `'before'` | `'middle'` ] - Placement
% of the vertical line on the time axis: in the middle of the specified
% period, immediately before it (between the specified period and the
% previous one), or immediately after it (between the specified period and
% the next one).
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

Ln = [];
Cp = [];

if ~isempty(varargin) ...
        && all(ishghandle(varargin{1})) ...
        && all( strcmp(get(varargin{1}(:),'type'),'axes') ...
        | strcmp(get(varargin{1}(:),'type'),'figure') )
    Ax = varargin{1};
    varargin(1) = [];
    nAx = numel(Ax);
    if nAx > 1
        for i = 1 : nAx
            iAx = Ax(i);
            [iLn,iCp] = grfun.vline(iAx,varargin{:});
            Ln = [Ln,iLn];
            Cp = [Cp,iCp];
        end
        return
    end
else
    Ax = gca();
end

% By now, `Ax` is a scalar handle to either an axes object or a figure
% window.

if strcmp(get(Ax,'type'),'figure')
    fig = Ax;
    Ax = findobj(fig,'type','axes','parent',fig);
    if numel(Ax) > 1
        [Ln,Cp] = grfun.vline(Ax,varargin{:});
    end
    return
end

% Horizontal location.
loc = varargin{1};
varargin(1) = [];

[opt,varargin] = passvalopt('grfun.vline',varargin{:});
varargin(1:2:end) = strrep(varargin(1:2:end),'=','');

%--------------------------------------------------------------------------

% Check for plotyy peers, and return the background axes object.
Ax = grfun.mychkforpeers(Ax);

% If this is a time series graph, convert the vline position to a date grid
% point.
x = loc;
if isequal(getappdata(Ax,'tseries'),true)
    x = dat2grid(x);
    freq = getappdata(Ax,'freq');
    if ~isempty(freq) && isnumericscalar(freq) ...
            && any(freq == [0,1,2,4,6,12])
        if freq > 0
            dx = 1/(2*freq);
        else
            dx = 0.5;
        end
        switch opt.timeposition
            case 'before'
                x = x - dx;
            case 'after'
                x = x + dx;
        end
    end
end

yLim = get(Ax,'yLim');
nextPlot = get(Ax,'nextPlot');
set(Ax,'nextPlot','add');

nLoc = numel(loc);
for i = 1 : nLoc

    ln = plot(Ax,x([i,i]),yLim);
    ln = ln(:).';
    
    ch = get(Ax,'children');
    for j = ln
        % Update the vline y-data whenever the parent y-lims change.
        grfun.listener(Ax,j,'vline');
        % Move the highlight patch object to the background.
        ch(ch == j) = [];
        ch(end+1) = j;
    end
    set(Ax,'children',ch);
    
    Ln = [Ln,ln]; %#ok<*AGROW>
    
    % Add annotation.
    if ~isempty(opt.caption)
        cp = grfun.mycaption(Ax,x(i), ...
            opt.caption,opt.vposition,opt.hposition);
        Cp = [Cp,cp(:).'];
    end
end

% Reset `'nextPlot='` to its original value.
set(Ax,'nextPlot',nextPlot);

if ~isempty(Ln)
    if ~isempty(varargin)
        set(Ln,'color',[0,0,0]);
        set(Ln,varargin{:});
    end
    
    % Tag the vlines and captions for `qstyle`.
    set(Ln,'tag','vline');
    set(Cp,'tag','vline-caption');
    
    % Exclude the line object from legend.
    if opt.excludefromlegend
        grfun.excludefromlegend(Ln);
    end
end

end
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
% * `'timePosition='` [ `'after'` | `'before'` | *`'middle'`* ] - Placement
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
% -Copyright (c) 2007-2014 IRIS Solutions Team.

Ln = zeros(1,0);
Cp = zeros(1,0);

if isempty(varargin)
    return
end

[Ax,Loc,varargin] = grfun.myaxinp(varargin{:});

if isempty(Ax) || isempty(Loc)
    return
end

nAx = length(Ax);
if nAx > 1
    for i = 1 : nAx
        [ln,cp] = grfun.vline(Ax(i),Loc,varargin{:});
        Ln = [Ln,ln]; %#ok<AGROW>
        Cp = [Cp,cp]; %#ok<AGROW>
    end
    return
end

pp = inputParser();
if ismatlab
pp.addRequired('H',@(x) all(ishghandle(x(:))) ...
    && all(strcmp(get(x,'type'),'axes')));
pp.addRequired('XPos',@isnumeric);
pp.parse(Ax,Loc);
else
pp = pp.addRequired('H',@(x) all(ishghandle(x(:))) ...
    && all(strcmp(get(x,'type'),'axes')));
pp = pp.addRequired('XPos',@isnumeric);
pp = pp.parse(Ax,Loc);
end

[opt,lineOpt] = passvalopt('grfun.vline',varargin{:});
lineOpt(1:2:end) = strrep(lineOpt(1:2:end),'=','');

%--------------------------------------------------------------------------

% Check for plotyy peers, and return the background axes object.
Ax = grfun.mychkforpeers(Ax);

% If this is a time series graph, convert the vline position to a date grid
% point.
x = Loc;
if isequal(getappdata(Ax,'tseries'),true)
    x = dat2dec(x,'centre');
    freq = getappdata(Ax,'freq');
    if ~isempty(freq) && is.numericscalar(freq) ...
            && any(freq == [0,1,2,4,6,12,52])
            dx = 0.5 / max(1,freq);
        switch opt.timeposition
            case 'before'
                x = x - dx;
            case 'after'
                x = x + dx;
        end
    end
end

if ismatlab
    yLim = realmax()*[-1,1]; % such a limits may cause OpenGL tesselation error in Octave
else
    yLim = get(Ax,'yLim');
end
nextPlot = get(Ax,'nextPlot');
set(Ax,'nextPlot','add');

nLoc = numel(Loc);
for i = 1 : nLoc

    ln = plot(Ax,x([i,i]),yLim,'yLimInclude','off');
    ln = ln(:).';
    
    % Temporary show excluded from legend (for Octave's way of excluding)
    if ~ismatlab
        grfun.mytrigexcludedfromlegend(Ax,'on');
    end
    
    ch = get(Ax,'children');
    for j = ln
        if ~ismatlab % keep old behaviour for Octave
            % Update the vline y-data whenever the parent y-lims change.
            grfun.listener(Ax,j,'vline');
        end
        % Move the vline object to the background.
        ch(ch == j) = [];
        ch(end+1) = j; %#ok<AGROW>
    end
    set(Ax,'children',ch);
    
    % Hide back excluded from legend (for Octave's way of excluding)
    if ~ismatlab
        grfun.mytrigexcludedfromlegend(Ax,'off');
    end
    
    Ln = [Ln,ln]; %#ok<AGROW>
    
    % Add annotation.
    if ~isempty(opt.caption)
        cp = grfun.mycaption(Ax,x(i), ...
            opt.caption,opt.vposition,opt.hposition);
        Cp = [Cp,cp(:).']; %#ok<AGROW>
    end
end

% Reset `'nextPlot='` to its original value.
set(Ax,'nextPlot',nextPlot);

if isempty(Ln)
    return
end

if ~isempty(lineOpt)
    set(Ln,'color',[0,0,0]);
    set(Ln,lineOpt{:});
end

% Tag the vlines and captions for `qstyle`.
set(Ln,'tag','vline');
set(Cp,'tag','vline-caption');

% Exclude the line object from legend.
if opt.excludefromlegend
    grfun.excludefromlegend(Ln);
end

end
function [Ln,Cp] = hline(varargin)
% zeroline  Add vertical line with text caption at the specified position.
%
% Syntax
% =======
%
%     Ln = hline(YPos,...)
%     Ln = hline(H,YPos,...)
%
% Input arguments
% ================
%
% * `'YPos`' [ numeric ] - Vertical position or vector of positions at
% which the horizontal line or lines will be drawn.
%
% * `H` [ numeric ] - Handle to an axes object (graph) or to a figure
% window in which the the horizontal line will be added; if not specified
% the line will be added to the current axes.
%
% Output arguments
% =================
%
% * `Ln` [ numeric ] - Handle to the line ploted (line object).
%
% Options
% ========
%
% * `'excludeFromLegend='` [ *`true`* | `false` ] - Exclude the line from
% legend.
%
% Any options valid for the standard `plot` function.
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
            [iLn,iCp] = grfun.hline(iAx,varargin{:});
            Ln = [Ln,iLn]; %#ok<AGROW>
            Cp = [Cp,iCp]; %#ok<AGROW>
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
        [Ln,Cp] = grfun.hline(Ax,varargin{:});
    end
    return
end

% Vertical location.
loc = varargin{1};
varargin(1) = [];

[opt,varargin] = passvalopt('grfun.hline',varargin{:});
varargin(1:2:end) = strrep(varargin(1:2:end),'=','');

%--------------------------------------------------------------------------

% Check for plotyy peers, and return the background axes object.
Ax = grfun.mychkforpeers(Ax);

yLim = get(Ax,'yLim');

xLim = get(Ax,'xLim');
nextPlot = get(Ax,'nextPlot');
set(Ax,'nextPlot','add');

for iLoc = loc(:).'
    if yLim(1) < iLoc && yLim(2) > iLoc
        ln = plot(Ax,xLim,[iLoc,iLoc]);
        Ln = [Ln,ln]; %#ok<AGROW>
        
        % Move zero line to background right below the last line.
        ch = get(Ax,'children');
        if length(ch) > 1
            set(Ax,'children',ch([2:end,1]));
        end
        
        % Update zeroline x-data whenever the parent axes x-lims change.
        grfun.listener(Ax,ln,'hline');
        
        cp = [];
        Cp = [Cp,cp]; %#ok<AGROW>
    end
end

% Reset `'nextPlot='` to its original value.
set(Ax,'nextPlot',nextPlot);

if ~isempty(Ln)
    set(Ln,'color',[0,0,0]);
    if ~isempty(varargin)
        set(Ln,varargin{:});
    end
    set(Ln,'tag','hline');
    if opt.excludefromlegend
        grfun.excludefromlegend(Ln);
    end
end

end
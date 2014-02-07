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
        [ln,cp] = grfun.hline(Ax(i),Loc,varargin{:});
        Ln = [Ln,ln]; %#ok<AGROW>
        Cp = [Cp,cp]; %#ok<AGROW>
    end
    return
end

pp = inputParser();
if ismatlab
pp.addRequired('H',@(x) all(ishghandle(x(:))) ...
    && all(strcmp(get(x,'type'),'axes')));
pp.addRequired('YPos',@isnumeric);
pp.parse(Ax,Loc);
else
pp = pp.addRequired('H',@(x) all(ishghandle(x(:))) ...
    && all(strcmp(get(x,'type'),'axes')));
pp = pp.addRequired('YPos',@isnumeric);
pp = pp.parse(Ax,Loc);
end

[opt,lineOpt] = passvalopt('grfun.hline',varargin{:});
lineOpt(1:2:end) = strrep(lineOpt(1:2:end),'=','');

%--------------------------------------------------------------------------

yLim = get(Ax,'yLim');

xLim = get(Ax,'xLim');
nextPlot = get(Ax,'nextPlot');
set(Ax,'nextPlot','add');

for iLoc = Loc
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
    if ~isempty(lineOpt)
        set(Ln,lineOpt{:});
    end
    set(Ln,'tag','hline');
    if opt.excludefromlegend
        grfun.excludefromlegend(Ln);
    end
end

end
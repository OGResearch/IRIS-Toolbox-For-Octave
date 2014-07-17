function [Ln,Cp] = myinfline(Ax,Dir,Loc,varargin)
% myinfline  [Not a public function] Add infintely stretched line at specified position.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

Ln = zeros(1,0);
Cp = zeros(1,0);

% Look for non-legend axes objects one level deep; this allows figure
% handles to be entered instead of axes objects.
Ax = findobj(Ax,'type','axes','-depth',1,'-not','tag','legend');

if isempty(Ax) || isempty(Dir) || isempty(Loc)
    return
end

nAx = length(Ax);
if nAx > 1
    for i = 1 : nAx
        [h,c] = grfun.myinfline(Ax(i),Dir,Loc,varargin{:});
        Ln = [Ln,h]; %#ok<AGROW>
        Cp = [Cp,c]; %#ok<AGROW>
    end
    return
end

pp = inputParser();
pp.addRequired('H',@(x) all(ishghandle(x(:))) ...
    && all(strcmp(get(x,'type'),'axes')));
pp.addRequired('Dir',@(x) ischar(x) && any(strncmpi(x,{'h','v'},1)));
pp.addRequired('Pos',@isnumeric);
pp.parse(Ax,Dir,Loc);

[opt,lineOpt] = passvalopt('grfun.infline',varargin{:});
lineOpt(1:2:end) = strrep(lineOpt(1:2:end),'=','');

%--------------------------------------------------------------------------

isVertical = strncmpi(Dir,'v',1);

% Check for plotyy peers, and return the background axes object.
% Ax = grfun.mychkforpeers(Ax);

% Vertical lines: If this is a time series graph, convert the vline
% position to a date grid point.
if isVertical
    if isequal(getappdata(Ax,'tseries'),true)
        Loc = dat2dec(Loc,'centre');
        freq = getappdata(Ax,'freq');
        if ~isempty(freq) && isnumericscalar(freq) ...
                && any(freq == [0,1,2,4,6,12,52])
            dx = 0.5 / max(1,freq);
            switch opt.timeposition
                case 'before'
                    Loc = Loc - dx;
                case 'after'
                    Loc = Loc + dx;
            end
        end
    end
end


nextPlot = get(Ax,'nextPlot');
set(Ax,'nextPlot','add');

if true % ##### MOSW
    infLim = 1e10;
else
    infLim = 1e5; %#ok<UNRCH>
end

if true % ##### MOSW
    bounds = objbounds(Ax);
else
    bounds = [0,0,0,0]; %#ok<UNRCH>
end
zPos = -1;

nLoc = numel(Loc);
for i = 1 : nLoc

    if isVertical
        xCoor = Loc([i,i]);
        yCoor = infLim*[-1,1] + bounds([3,4]);
    else
        xCoor = infLim*[-1,1] + bounds([1,2]);
        yCoor = Loc([i,i]);
    end
    zCoor = zPos*ones(size(xCoor));
    h = line(xCoor,yCoor,zCoor,'color',[0,0,0], ...
        'yLimInclude','off','xLimInclude','off');
    
    Ln = [Ln,h]; %#ok<AGROW>
    
    % Add annotation.
    if ~isempty(opt.caption) && isVertical
        c = grfun.mycaption(Ax,Loc(i), ...
            opt.caption,opt.vposition,opt.hposition);
        Cp = [Cp,c]; %#ok<AGROW>
    end
end

% Reset `'nextPlot='` to its original value.
set(Ax,'nextPlot',nextPlot);

% Make sure zLim includes zPos.
zLim = get(Ax,'zLim');
zLim(1) = min(zLim(1),zPos);
set(Ax,'zLim',zLim);

if isempty(Ln)
    return
end

if ~isempty(lineOpt)  
    set(Ln,lineOpt{:});
end

% Tag the lines and captions for `qstyle`.
if isVertical
    set(Ln,'tag','vline');
    set(Cp,'tag','vline-caption');
else
    set(Ln,'tag','hline');
end

if true % ##### MOSW
    if opt.excludefromlegend
        % Exclude the line object from legend.
        grfun.excludefromlegend(Ln);
    end
else
    % Do nothing.
end

end

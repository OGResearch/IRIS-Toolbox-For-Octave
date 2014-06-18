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
Ax = grfun.mychkforpeers(Ax);

% Vertical lines: If this is a time series graph, convert the vline
% position to a date grid point.
if isVertical
    if isequal(getappdata(Ax,'tseries'),true)
        Loc = dat2dec(Loc,'centre');
        freq = getappdata(Ax,'freq');
        if ~isempty(freq) && is.numericscalar(freq) ...
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

%infLim = realmax()*[-1,1];
infLim = 1e10*[-1,1];

nextPlot = get(Ax,'nextPlot');
set(Ax,'nextPlot','add');

nLoc = numel(Loc);
for i = 1 : nLoc

    % Draw vlines as patch objects. Lines do not work with realmax in older
    % Matlab releases with HG1.
    if isVertical
        xCoor = Loc([i,i]);
        yCoor = infLim;
    else
        xCoor = infLim;
        yCoor = Loc([i,i]);
    end
    h = patch(xCoor,yCoor,[0,0,0], ...
       'parent',Ax,'edgeColor',[0,0,0],'faceColor','none', ...
       'yLimInclude','off','xLimInclude','off');
    
    ch = get(Ax,'children');
    % Move the vline object to the background
    ch(ch == h) = [];
    ch(end+1) = h; %#ok<AGROW>
    set(Ax,'children',ch);
    
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

% Exclude the line object from legend.
if opt.excludefromlegend
    grfun.excludefromlegend(Ln);
end

end
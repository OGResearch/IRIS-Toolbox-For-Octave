function plot(This,Ax)
% plot  [Not a public function] Draw report/graph object.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isempty(This.children)
    return
end

% Clear the axes object.
cla(Ax);

% Run user-supplied style pre-processor on the axes object.
if ~isempty(This.options.preprocess)
    grfun.mystyleprocessor(Ax,This.options.preprocess);
end

% Array of legend entries.
legendEntries = {};

nChild = length(This.children);

lhsInx = false(1,nChild);
rhsInx = false(1,nChild);
annotateInx = false(1,nChild);
doIsLhsOrRhsOrAnnotate();
isRhs = any(rhsInx);

if isRhs
    % Plot functions `@plotyy`, `@plotcmp`, `@barcon` not allowed.
    doChkPlotFunc();
    % Legend location cannot be `best` in LHS-RHS plots. This is a Matlab
    % issue.
    doLegendLocation();
    % Create an axes object for the RHS plots.
    doOpenRhsAxes();
end

doHoldAll();
doPlot();

if isRhs
    grfun.swaplhsrhs(Ax(1),Ax(2));
end

if This.options.grid
    grid(Ax(1),'on');
end

if ~isequal(This.options.zeroline,false)
    zerolineOpt = {};
    if iscell(This.options.zeroline)
        zerolineOpt = This.options.zeroline;
    end
    grfun.zeroline(Ax(1),zerolineOpt{:});
end

% Make the y-axis tight if requested by the user. Only after that the vline
% children can be plotted.
if This.options.tight
    grfun.yaxistight(Ax(1));
end

% Plot highlight and vline. These are excluded from legend.
for i = find(annotateInx)
    plot(This.children{i},Ax(end));
end

% Find children tagged `'background'` and move them to background.
ch = get(Ax(end),'children');
bg = findobj(ch,'flat','tag','background');
for ibg = bg(:).'
    ch(ch == ibg) = [];
end
ch = [ch;bg];
set(Ax(end),'children',ch);

% Add legend.
lg = [];
if isequal(This.options.legend,true) ...
        || (isnumeric(This.options.legend) && ~isempty(This.options.legend))
    if isnumeric(This.options.legend) && ~isempty(This.options.legend)
        % Select only the legend entries specified by the user.
        legendEntries = legendEntries(This.options.legend);
    end
    legendEntries = [legendEntries{:}];
    if ~isempty(legendEntries) && ~all(cellfun(@isempty,legendEntries))
        if strcmp(This.options.legendlocation,'bottom')
            lg = grfun.bottomlegend(Ax(1),legendEntries{:});
        else
            lg = legend(Ax(1),legendEntries{:}, ...
                'location',This.options.legendlocation);
            
        end
        set(lg,'color','white');
    end
end

% Add title and/or subtitle to the graph. If the legend is located
% NorthOutside, create the title in the legend axes object.
titleCell = {This.title,This.subtitle};
ixEmpty = cellfun(@isempty,titleCell);
titleCell(ixEmpty) = [];
if ~isempty(titleCell)
    if ~isempty(lg) && strcmpi(get(lg,'Location'),'northOutside')
        tt = get(lg,'title');
        set(tt,'string',titleCell,'interpreter','none', ...
            'visible','on');
    else
        title(titleCell,'interpreter','none');
    end
end

% Annotate axes.
if ~isempty(This.options.xlabel)
    xlabel(Ax,This.options.xlabel);
end
if ~isempty(This.options.ylabel)
    ylabel(Ax,This.options.ylabel);
end
if ~isempty(This.options.zlabel)
    zlabel(Ax,This.options.zlabel);
end

if ~isempty(This.options.style)
    % Apply styles to the axes object and its children.
    qstyle(This.options.style,Ax,'warning',false);
    if ~isempty(lg)
        % Apply styles to the legend axes.
        qstyle(This.options.style,lg,'warning',false);
    end
end

% Run user-supplied axes options.
if ~isempty(This.options.axesoptions)
    set(Ax(1),This.options.axesoptions{:});
    if isRhs
        set(Ax(end),This.options.axesoptions{:});
        set(Ax(end),This.options.rhsaxesoptions{:});
    end
end

% Run user-supplied style post-processor.
if ~isempty(This.options.postprocess)
    grfun.mystyleprocessor(Ax,This.options.postprocess);
end


% Nested functions...


%**************************************************************************


    function doOpenRhsAxes()
        Ax = plotyy(Ax,NaN,NaN,NaN,NaN);
        delete(get(Ax(1),'children'));
        delete(get(Ax(2),'children'));
    end % doOpenRhsAxes()


%**************************************************************************


    function doHoldAll()
        % This is `hold all`.
        for iAx = Ax(:).'
            set(iAx,'nextPlot','add');
            setappdata(iAx,'PlotHoldStyle',true);
            set(iAx,'yLimMode','auto','yTickMode','auto');
        end
        % Change grid line style back to black dotted line in HG2; see
        % remarks in grfun.highlight.
        if is.hg2()
            set(Ax,'gridLineStyle',':', ...
                'gridColor',0.7*[1,1,1]);
        end
        setappdata(Ax(1),'PlotColorIndex',0);
        if length(Ax) > 1
            set(Ax(2),'cLim',[-5,5]);
            setappdata(Ax(2),'PlotColorIndex',2);
        end
    end % doHoldAll()


%**************************************************************************


    function doPlot()
        for ii = 1 : nChild
            if lhsInx(ii)
                legendEntries{end+1} = ...
                    plot(This.children{ii},Ax(1)); %#ok<AGROW>
            elseif rhsInx(ii)
                legendEntries{end+1} = ...
                    plot(This.children{ii},Ax(2)); %#ok<AGROW>
            end
        end
    end % doPlotLhs()


%**************************************************************************


    function doIsLhsOrRhsOrAnnotate()        
        for ii = 1 : nChild
            ch = This.children{ii};
            if isfield(ch.options,'yaxis') ...
                    && strcmpi(ch.options.yaxis,'right');
                rhsInx(ii) = true;
            elseif isa(ch,'report.annotateobj')
                annotateInx(ii) = true;
            else
                lhsInx(ii) = true;
            end
        end
        
    end % doIsLhsOrRhsOrAnnotate()


%**************************************************************************


    function doChkPlotFunc()
        invalid = {};
        for ii = find(lhsInx | rhsInx)
            ch = This.children{ii};
            if ~any(strcmpi(char(ch.options.plotfunc), ...
                    {'plot','bar','stem','area'}))
                invalid{end+1} = char(ch.options.plotfunc); %#ok<AGROW>
            end
        end
        if ~isempty(invalid)
            utils.error('report', ...
                ['This plot function is not allowed in graphs ', ...
                'with LHS and RHS axes: ''%s''.'], ...
                invalid{:});
        end
    end % doChkPlotFunc()


%**************************************************************************


    function doLegendLocation()
        if strcmpi(This.options.legendlocation,'best')
            This.options.legendlocation = 'South';
            utils.warning('report', ...
                ['Legend location cannot be ''Best'' in LHS-RHS graphs. ', ...
                '(This is a Matlab issue.) Setting the location to ''South''.']);
        end
    end % doLegendLocation()


end
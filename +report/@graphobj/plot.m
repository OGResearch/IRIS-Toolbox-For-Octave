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
legEnt = cell(1,0);

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

if isequal(This.options.grid,@auto)
    This.options.grid = ~isRhs;
end

if isequal(This.options.tight,@auto)
    This.options.tight = ~isRhs;
end

hold(Ax(1),'all');
if isRhs
    hold(Ax(end),'all');
end

doPlot();

if This.options.grid
    grid(Ax(end),'on');
end

if ~isequal(This.options.zeroline,false)
    zerolineOpt = {};
    if iscell(This.options.zeroline)
        zerolineOpt = This.options.zeroline;
    end
    grfun.zeroline(Ax(end),zerolineOpt{:});
end

% Make the y-axis tight if requested by the user. Only after that the vline
% children can be plotted.
if This.options.tight
    grfun.yaxistight(Ax(end));
end

% Add title and subtitle (must be done before the legend).
titleCell = {This.title,This.subtitle};
ixEmpty = cellfun(@isempty,titleCell);
titleCell(ixEmpty) = [];
if ~isempty(titleCell)
    ti = title(titleCell,'interpreter','none');
    if ~isempty(This.options.titleoptions)
        set(ti,This.options.titleoptions{:});
    end
end

% Add legend.
lg = [];
if isequal(This.options.legend,true) ...
        || (isnumeric(This.options.legend) && ~isempty(This.options.legend))
    if isnumeric(This.options.legend) && ~isempty(This.options.legend)
        % Select only the legend entries specified by the user.
        legEnt = legEnt(This.options.legend);
    end
    legEntLhs = [legEnt{ixLegLhs}];
    legEngRhs = [legEnt{~ixLegLhs}]; %#ok<NASGU>
    if true % ##### MOSW
        % Do nothing
    else
        % Temporarily make invisible those excluded from legend
        kids = findall(Ax(1)); %#ok<UNRCH>
        toTrig = isappdata(kids,'notInLegend');
        hvstat = get(kids(toTrig),'handleVisibility');
        set(kids(toTrig),'handleVisibility','off');
    end
    % TODO: Create legend for RHS data.
    if ~isempty(legEnt) && ~all(cellfun(@isempty,legEnt))
        if strcmp(This.options.legendlocation,'bottom')
            lg = grfun.bottomlegend(Ax(1),legEntLhs{:});
        else
            lg = legend(Ax(1),legEntLhs{:}, ...
                'location',This.options.legendlocation);
            if ~isempty(This.options.legendoptions)
                set(lg,This.options.legendoptions{:});  
            end
        end
    end
    if true % ##### MOSW
        % Do nothing
    else
        % Temporarily make all visible back
        set(kids(toTrig),{'handleVisibility'},hvstat); %#ok<UNRCH>
    end
end

if isRhs
    grfun.swaplhsrhs(Ax(1),Ax(2));
end

% Plot highlight and vline. These are excluded from legend.
for i = find(annotateInx)
    plot(This.children{i},Ax(1));
end

% Annotate axes.
if ~isempty(This.options.xlabel)
    xlabel(Ax(1),This.options.xlabel);
end
if ~isempty(This.options.ylabel)
    ylabel(Ax(1),This.options.ylabel);
end
if ~isempty(This.options.zlabel)
    zlabel(Ax(1),This.options.zlabel);
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
        set(Ax, ...
            'box','off', ...
            'YColor',get(Ax(1),'XColor'), ...
            'XLimMode','auto','XTickMode','auto', ...
            'YLimMode','auto','YTickMode','auto');
        set(Ax(2),'ColorOrder',get(Ax(1),'ColorOrder'));
        if true % ##### MOSW
            try
                % HG2.
                set(Ax,'ColorOrderIndex',1);
                Ax(1).XRuler.Visible = 'on';
                Ax(2).XRuler.Visible = 'on';
            catch
                % HG1.
                setappdata(Ax(1),'PlotColorIndex',1);
                setappdata(Ax(2),'PlotColorIndex',1);
            end
        else
            % Do nothing.
        end
    end % doOpenRhsAxes()


%**************************************************************************


    function doPlot()
        legEnt = cell(1,nChild);
        ixLegLhs = true(1,nChild);
        for ii = 1 : nChild
            if lhsInx(ii)
                % Plot on the LHS.
                legEnt{ii} = plot(This.children{ii},Ax(1));
            elseif rhsInx(ii)
                % Plot on the RHS.
                legEnt{ii} = plot(This.children{ii},Ax(2));
                ixLegLhs(ii) = false;
            end
            if isRhs
                % In graphs with LHS and RHS axes, keep the color order index the same in
                % Ax(1) and Ax(2) at all times.
                if true % ##### MOSW
                    try
                        % HG2.
                        cix = get(Ax,'ColorOrderIndex');
                        cix = max([cix{:}]);
                        set(Ax,'ColorOrderIndex',cix);
                    catch
                        % HG1.
                        cix1 = getappdata(Ax(1),'PlotColorIndex');
                        cix2 = getappdata(Ax(2),'PlotColorIndex');
                        cix = max([cix1,cix2]);
                        setappdata(Ax(1),'PlotColorIndex',cix);
                        setappdata(Ax(2),'PlotColorIndex',cix);
                    end
                else
                    % Do nothing.
                end
            end
        end
    end % doPlotLhs()


%**************************************************************************


    function doIsLhsOrRhsOrAnnotate()
        for ii = 1 : nChild
            ch = This.children{ii};
            if isfield(ch.options,'yaxis')
                if strcmpi(ch.options.yaxis,'right')
                    rhsInx(ii) = true;
                else
                    lhsInx(ii) = true;
                end
            else
                annotateInx(ii) = true;
            end
        end
        
    end % doIsLhsOrRhsOrAnnotate()


%**************************************************************************


    function doChkPlotFunc()
        invalid = {};
        for ii = find(lhsInx | rhsInx)
            ch = This.children{ii};
            if ~isanyfunc(ch.options.plotfunc, ...
                    {'plot','bar','stem','area'})
                invalid{end+1} = func2str(ch.options.plotfunc); %#ok<AGROW>
            end
        end
        if ~isempty(invalid)
            utils.error('graphobj:plot', ...
                ['This plot function is not allowed in graphs ', ...
                'with LHS and RHS axes: ''%s''.'], ...
                invalid{:});
        end
    end % doChkPlotFunc()


%**************************************************************************


    function doLegendLocation()
        if strcmpi(This.options.legendlocation,'best')
            This.options.legendlocation = 'South';
            utils.warning('graphobj:plot', ...
                ['Legend location cannot be ''Best'' in LHS-RHS graphs. ', ...
                '(This is a Matlab issue.) Setting the location to ''South''.']);
        end
    end % doLegendLocation()


end

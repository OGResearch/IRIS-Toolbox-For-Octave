function mydatxtick(H,Range,Time,Freq,UserRange,Opt)
% mydatxtick  [Not a public function] Set up x-axis for tseries object graphs.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

if length(H) > 1
    for iH = H(:).'
        mydatxtick(iH,Time,Freq,UserRange,Opt);
    end
    return
end

%--------------------------------------------------------------------------

try
    if isequaln(Time,NaN)
        return
    end
catch %#ok<CTCH>
    if isequaln(Time,NaN) %#ok<FPARK>
        return
    end
end

% Does the axies object have a plotyy peer? Set the peer's xlim-related
% properties the same as in H; do not though set its xtick-related
% properties.
peer = getappdata(H,'graphicsPlotyyPeer');

% Determine x-limits first.
firstDate = [];
lastDate = [];
xLim = [];
doXLim();

% Allow temporarily auto ticks and labels.
set(H, ...
    'xTickMode','auto', ...
    'xTickLabelMode','auto');

xTick = get(H(1),'xTick');
xTickDates = [];
if Freq == 0
    doXTickZero();
else
    doXTick();
end

% Adjust x-limits if the graph includes bars.
doXLimAdjust();


% Nested functions...


%**************************************************************************
    function doXLim()
        if isequal(UserRange,Inf)
            if Freq == 0
                firstDate = Range(1);
                lastDate = Range(end);
                xLim = [firstDate,lastDate];
            elseif Freq == 52
                firstDate = Range(1);
                lastDate = Range(end);
                xLim = [Time(1),Time(end)];
            else
                % First period in first plotted year to last period in last plotted year.
                firstDate = datcode(Freq,floor(Time(1)),1);
                lastDate = datcode(Freq,floor(Time(end)),Freq);
                xLim = dat2dec([firstDate,lastDate],Opt.dateposition);
            end
        else
            firstDate = UserRange(1);
            lastDate = UserRange(end);
            xLim = dat2dec([firstDate,lastDate],Opt.dateposition);
        end
        set([H,peer], ...
            'xLim',xLim, ...
            'xLimMode','manual');
    end % doXLim()


%**************************************************************************
    function doXTick()
        if isequal(Opt.datetick,Inf)
            % Determine step and xTick.
            % Step is number of periods.
            % If multiple axes handles are passed in (e.g. plotyy) use just
            % the first one to get xTick but set the properties for both
            % eventually.
            if length(xTick) > 1
                step = max(1,round(Freq*(xTick(2) - xTick(1))));
            else
                step = 1;
            end
            xTickDates = firstDate : step : lastDate;
        elseif isnumeric(Opt.datetick)
            xTickDates = Opt.datetick;
        elseif ischar(Opt.datetick)
            tempRange = firstDate : lastDate;
            [~,tempPer] = dat2ypf(tempRange);
            switch lower(Opt.datetick)
                case 'yearstart'
                    xTickDates = tempRange(tempPer == 1);
                case 'yearend'
                    xTickDates = tempRange(tempPer == Freq);
                case 'yearly'
                    match = tempPer(1);
                    if Freq == 52 && match == 53
                        match = 52;
                        xTickDates = tempRange(tempPer == match);
                        xTickDates = [tempRange(1),xTickDates];
                    else
                        xTickDates = tempRange(tempPer == match);
                    end
            end
        end
        xTick = dat2dec(xTickDates,Opt.dateposition);
        doSetXTickLabel();
    end % doXTick()


%**************************************************************************
    function doXTickZero()
        % Make sure the xTick step is not smaller than 1.
        if isinf(Opt.datetick)
            if any(diff(xTick) < 1)
                xTick = xTick(1) : xTick(end);
                set(H, ...
                    'xTick',xTick', ...
                    'xTickMode','manual');
            end
        else
            xTick = Opt.datetick;
            set(H,...
                'xTick',xTick,...
                'xTickMode','manual');
        end
        if strncmp(Opt.dateformat,'$',1)
            doSetXTickLabel();
        end
    end % doXTickZero()


%**************************************************************************
    function doSetXTickLabel()
        set(H, ...
            'xTick',xTick, ...
            'xTickMode','manual');
        % Set xTickLabel.
        Opt = datdefaults(Opt,true);
        % Plot date format can be a cellstr under two circumstances:
        %
        % * either the user specifies different date formats for the first,
        % second, etc. dates plotted in the graph,
        %
        % * or the `'dateformat='` option comes from `irisconfig` where it
        % is set up as a cellstr with different date formats for each of
        % the recognized frequencies.
        %
        % If it is the second case, choose the
        % correct date format now. If it is the first case, pass the
        % `'dateFormat='` option into the `dat2str` function.
        freqList = [1,2,4,6,12,52];
        if iscell(Opt.dateformat) ...
                && length(Opt.dateformat) == length(freqList)
            inx = Freq == freqList;
            if ~isempty(inx)
                Opt.dateformat = Opt.dateformat{inx};
            else
                utils.error('dates:mydatxtick', ...
                    'Cannot recognize date frequency in a plot command.');
            end
        end
        xTickLabel = dat2str(xTickDates,Opt);
        set(H, ...
            'xTickLabel',xTickLabel, ...
            'xTickLabelMode','manual');
    end % doSetXTickLabel()


%**************************************************************************
    function doXLimAdjust()
        % Expand x-limits for bar graphs, or make sure they are kept wide if a bar
        % graph is added a non-bar plot.
        if isequal(getappdata(H,'xLimAdjust'),true)
            if Freq > 0
                xLimAdjust = 0.5/Freq;
            else
                xLimAdjust = 0.5;
            end
            xLim = get(H,'xLim');
            set([H,peer],'xLim',xLim + [-xLimAdjust,xLimAdjust]);
            setappdata(H,'trueXLim',xLim);
            if ~isempty(peer)
                setappdata(peer,'trueXLim',xLim);
            end
        end
    end % doXLimAdjust()


end
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
    if isequalwithequalnans(Time,NaN) %#ok<FPARK>
        return
    end
end

% Does the axies object have a plotyy peer? Set the peer's xlim-related
% properties the same as in H; do not though set its xtick-related
% properties.
if true % ##### MOSW
    peer = getappdata(H,'graphicsPlotyyPeer');
else
    peer = [];
    try
        peer = get(H,'__plotyy_axes__'); %#ok<UNRCH>
    end
    peer = peer(peer ~= H);
end

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
            utils.error('dates:mydatxtick', ...
                ['Inf is an obsolete value for the option ''dateTick=''. ', ...
                'Use @auto instead.']);
        elseif isequal(Opt.datetick,@auto)
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
        if isequal(Opt.datetick,Inf)
            utils.error('dates:mydatxtick', ...
                ['Inf is an obsolete value for the option ''dateTick=''. ', ...
                'Use @auto instead.']);
        elseif isequal(Opt.datetick,@auto)
            % Do nothing.
        else
            xTick = Opt.datetick;
        end
        if any(diff(xTick) < 1)
            xTick = xTick(1) : xTick(end);
        end
        set(H, ...
            'xTick',xTick', ...
            'xTickMode','manual');
        if strncmp(Opt.dateformat,'$',1)
            xTickDates = xTick;
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
        % Default value for '.plotDateFormat' is a struct with a different
        % date format for each date frequency. Fetch the right date format
        % now, and pass it into `dat2str()`.
        if isstruct(Opt.dateformat)
            switch Freq
                case 1
                    Opt.dateformat = Opt.dateformat.yy;
                case 2
                    Opt.dateformat = Opt.dateformat.hh;
                case 4
                    Opt.dateformat = Opt.dateformat.qq;
                case 6
                    Opt.dateformat = Opt.dateformat.bb;
                case 12
                    Opt.dateformat = Opt.dateformat.mm;
                case 52
                    Opt.dateformat = Opt.dateformat.ww;
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
function mydatxtick(H,Time,Freq,UserRange,Opt)
% mydatxtick  [Not a public function] Set up x-axis for tseries object graphs.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

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
peer = getappdata(H,'graphicsPlotyyPeer');

% Determine x-limits first.
first = [];
last = [];
doFirst();
doLast();
xLim = [first,last];
if Freq > 0
    xLim = dat2grid(xLim,Opt.dateposition);
end
set([H,peer], ...
    'xLim',xLim, ...
    'xLimMode','manual');

% Allow temporarily auto ticks and labels.
set(H, ...
    'xTickMode','auto', ...
    'xTickLabelMode','auto');

xTick = [];
if Freq == 0
    doZeroFreq();
else
    doNormalFreq();
end

% Adjust x-limits if the graph includes bars.
doXLimAdjust();

% Nested functions.

%**************************************************************************
    function doFirst()
        first = UserRange(1);
        if isinf(first)
            if Freq > 0
                % Lower limit if user entered Inf: First period in first plotted
                % year.
                first = datcode(Freq,floor(Time(1)),1);
            else
                first = Time(1);
            end
        end
    end % doFirst().

%**************************************************************************
    function doLast()
        last = UserRange(end);
        if isinf(last)
            if Freq > 0
                % Upper limit if user entered Inf: Last period in last plotted
                % year.
                last = datcode(Freq,floor(Time(end)),Freq);
            else
                last = Time(end);
            end
        end
    end % doLast().

%**************************************************************************
    function doNormalFreq()
        if isequal(Opt.datetick,Inf)
            % Determine step and xTick.
            % Step is number of periods.
            % If multiple axes handles are passed in (e.g. plotyy) use just
            % the first one to get xTick but set the properties for both
            % eventually.
            xTick = get(H(1),'xTick');
            if length(xTick) > 1
                step = round(Freq*(xTick(2) - xTick(1)));
            else
                step = 1;
            end
            if step < 1
                step = 1;
            end
            if step < Freq
                % Make sure freq/step is integer.
                if rem(Freq,step) > 0
                    step = Freq / floor(Freq/step);
                end
            elseif step > Freq
                % Make sure step/freq is integer.
                if rem(step,Freq) > 0
                    step = Freq * floor(step/Freq);
                end
            end
            nstep = round(Freq/step*(xLim(2) - xLim(1)));
            xTick = xLim(1) + step/Freq*(0 : nstep);
        elseif isnumeric(Opt.datetick)
            xTick = dat2grid(Opt.datetick,Opt.dateposition);
        elseif ischar(Opt.datetick)
            switch lower(Opt.datetick)
                case 'yearstart'
                    temprange = first : last;
                    [ans,tempper] = dat2ypf(temprange); %#ok<NOANS,ASGLU>
                    xTick = dat2grid( ...
                        temprange(tempper == 1), ...
                        Opt.dateposition);
                case 'yearend'
                    temprange = first : last;
                    [ans,tempper] = dat2ypf(temprange); %#ok<NOANS,ASGLU>
                    xTick = dat2grid( ...
                        temprange(tempper == Freq), ...
                        Opt.dateposition);
                case 'yearly'
                    xTick = dat2grid( ...
                        first : Freq : last, ...
                        Opt.dateposition);
            end
        end
        doSetXTick();
    end % doNormalFreq().

%**************************************************************************
    function doZeroFreq()
        % Make sure the xTick step is not smaller than 1.
        if isinf(Opt.datetick)
            xTick = get(H(1),'xTick');
            if any(diff(xTick) < 1)
                xTick = xTick(1) : xTick(end);
                set(H, ...
                    'xTick',xTick', ...
                    'xTickMode','manual');
            end
        else
            set(H,...
                'xTick',Opt.datetick,...
                'xTickMode','manual');
        end
        if strncmp(Opt.dateformat,'$',1)
            doSetXTick();
        end
    end % doZeroFreq().

%**************************************************************************
    function doSetXTick()
        set(H, ...
            'xTick',xTick, ...
            'xTickMode','manual');
        % Set xTickLabel.
        Opt = datdefaults(Opt,true);
        xTickLabel = ...
            dat2str(grid2dat(xTick,Freq,Opt.dateposition),Opt);
        set(H, ...
            'xTickLabel',xTickLabel, ...
            'xTickLabelMode','manual');
    end % doSetXTick().

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
    end % doXLimAdjust().

end
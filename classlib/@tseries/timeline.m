function timeline(H,TIME,USERRANGE,FREQ,OPT)
% timeline  [Not a public function] Set up x-axis for tseries object graphs.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%**************************************************************************

try
    if isequaln(TIME,NaN)
        return
    end
catch %#ok<CTCH>
    if isequalwithequalnans(TIME,NaN) %#ok<FPARK>
        return
    end
end

% Determine and set x-limits.
first = [];
last = [];
dofirst();
dolast();
xlim = [first,last];
if FREQ > 0
    xlim = dat2grid(xlim,OPT.dateposition);
end
set(H, ...
    'xLim',xlim, ...
    'xLimMode','manual');

xTick = [];
if FREQ == 0
    dozerofreq();
else
    donormalfreq();
end

% Nested functions.

%**************************************************************************
    function dofirst()
        first = USERRANGE(1);
        if isinf(first)
            if FREQ > 0
                % Lower limit if user entered Inf: First period in first plotted
                % year.
                first = datcode(FREQ,floor(TIME(1)),1);
            else
                first = TIME(1);
            end
        end
    end % dofirst().

%**************************************************************************
    function dolast()
        last = USERRANGE(end);
        if isinf(last)
            if FREQ > 0
                % Upper limit if user entered Inf: Last period in last plotted
                % year.
                last = datcode(FREQ,floor(TIME(end)),FREQ);
            else
                last = TIME(end);
            end
        end
    end % dolast().

%**************************************************************************
    function donormalfreq()
        if isequal(OPT.datetick,Inf)
            % Determine step and xTick.
            % Step is number of periods.
            % If multiple axes handles are passed in (e.g. plotyy) use just
            % the first one to get xTick but set the properties for both
            % eventually.
            xTick = get(H(1),'xTick');
            if length(xTick) > 1
                step = round(FREQ*(xTick(2) - xTick(1)));
            else
                step = 1;
            end
            if step < 1
                step = 1;
            end
            if step < FREQ
                % Make sure freq/step is integer.
                if rem(FREQ,step) > 0
                    step = FREQ / floor(FREQ/step);
                end
            elseif step > FREQ
                % Make sure step/freq is integer.
                if rem(step,FREQ) > 0
                    step = FREQ * floor(step/FREQ);
                end
            end
            nstep = round(FREQ/step*(xlim(2) - xlim(1)));
            xTick = xlim(1) + step/FREQ*(0 : nstep);
        elseif isnumeric(OPT.datetick)
            xTick = dat2grid(OPT.datetick,OPT.dateposition);
        elseif ischar(OPT.datetick)
            switch lower(OPT.datetick)
                case 'yearstart'
                    temprange = first : last;
                    [ans,tempper] = dat2ypf(temprange); %#ok<NOANS,ASGLU>
                    xTick = dat2grid( ...
                        temprange(tempper == 1), ...
                        OPT.dateposition);
                case 'yearend'
                    temprange = first : last;
                    [ans,tempper] = dat2ypf(temprange); %#ok<NOANS,ASGLU>
                    xTick = dat2grid( ...
                        temprange(tempper == FREQ), ...
                        OPT.dateposition);
                case 'yearly'
                    xTick = dat2grid( ...
                        first : FREQ : last, ...
                        OPT.dateposition);
            end
        end
        dosetxtick();
    end
% do_normalfreq().

%**************************************************************************
    function dozerofreq()
        % Make sure the xTick step is not smaller than 1.
        if isinf(OPT.datetick)
            xTick = get(H(1),'xTick');
            if any(diff(xTick) < 1)
                xTick = xTick(1) : xTick(end);
                set(H, ...
                    'xTick',xTick', ...
                    'xTickMode','manual');
            end
        else
            set(H,...
                'xTick',OPT.datetick,...
                'xTickMode','manual');
        end
        if strncmp(OPT.dateformat,'$',1)
            dosetxtick();
        end
    end
% do_zerofreq().

%**************************************************************************
    function dosetxtick()
        set(H, ...
            'xTick',xTick, ...
            'xTickMode','manual');
        % Set xTickLabel.
        OPT = datdefaults(OPT,true);
        label = ...
            dat2str(grid2dat(xTick,FREQ,OPT.dateposition),OPT);
        set(H, ...
            'xTickLabel',label, ...
            'xTickLabelMode','manual');
    end
% dosetxticklabel().

end


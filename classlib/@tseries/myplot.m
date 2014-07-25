function [H,Rng,Data,Time,UsrRng,Freq,varargout] = myplot(Func,varargin)
% myplot  [Not a public function] Master plot function for tseries objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

% If the caller supplies empty `Func`, the graph will not be actually
% rendered. This is a dry call to `myplot` used from within `plotyy`.

% User-specified handle to axes. Otherwise, the gca will be used. Make
% sure this complies with future Matlab graphics implementation where
% handles will no longer be numerics.
if length(varargin{1}) == 1 && ishghandle(varargin{1})
    Ax = varargin{1}(1);
    varargin(1) = [];
elseif ~isempty(Func)
    Ax = gca();
else
    Ax = [];
end

% User-defined range. Otherwise the entire range of the tseries object
% will be plotted. A cell array is passed in by the `plotyy` function to
% also indicate the other axes' range that must be comprised by the current
% one.
if isnumeric(varargin{1})
    comprise = [];
    Rng = varargin{1};
    varargin(1) = [];
elseif iscell(varargin{1}) && length(varargin{1}) == 2 ...
        && all(cellfun(@isnumeric,varargin{1}))
    comprise = varargin{1}{2};
    Rng = varargin{1}{1};
    varargin(1) = [];
else
    comprise = [];
    Rng = Inf;
end

UsrRng = Rng;

% Tseries object that will be plotted.
X = varargin{1};
varargin(1) = [];

X = resize(X,Rng);

flag = true;
plotSpecs = {};
if length(varargin) == 1 && ischar(varargin{1})
    plotSpecs = varargin(1);
    varargin(1) = [];
end
[opt,varargin] = passvalopt('tseries.myplot',varargin{:});

% In shortcut line specification, we allow for date format to be
% included after a |.
if ~isempty(plotSpecs)
    inx = find(plotSpecs{1} == '|',1);
    if ~isempty(inx)
        opt.dateformat = plotSpecs{1}(inx+1:end);
        plotSpecs{1} = plotSpecs{1}(1:inx-1);
    end
end

if ~flag
    utils.error('tseries:myplot','Incorrect type of input argument(s).');
end

%--------------------------------------------------------------------------

X.data = X.data(:,:);
[~,nx] = size(X.data);
Rng = specrange(X,Rng);

H = [];
if isempty(Rng)
    utils.warning('tseries:myplot', ...
        'No graph displayed because date range is empty.');
    return
end

Freq = datfreq(Rng(1));

% If hold==on, make sure the new range comprises thes existing dates if
% the existing graph is a tseries graph.
if ~isempty(Func) ...
        && ~isempty(Rng) && strcmp(get(Ax,'nextPlot'),'add') ...
        && isequal(getappdata(Ax,'tseries'),true)
    % Original x-axis limits.
    if isequal(getappdata(Ax,'xLimAdjust'),true)
        xLim0 = getappdata(Ax,'trueXLim');
    else
        xLim0 = get(Ax,'xLim');
    end
    Rng = doMergeRange(Rng([1,end]),xLim0);
end

% Make sure the new range and `userrange` both comprise the `comprise`
% dates; this is used in `plotyy`.
if ~isempty(comprise)
    Rng = doMergeRange(Rng,comprise);
    if ~isequal(UsrRng,Inf)
        UsrRng = doMergeRange(UsrRng,comprise);
    end
end

Data = mygetdata(X,Rng);
Time = dat2dec(Rng,opt.dateposition);

if isempty(Func)
    return
end

% Do the actual plot.
set(Ax,'xTickMode','auto','xTickLabelMode','auto');
H = [];
doPlot();

if isequal(opt.xlimmargin,true) ...
        || (ischar(opt.xlimmargin) ...
        && strcmpi(opt.xlimmargin,'auto') ...
        && isanyfunc(Func,{'bar','barcon'}))
    setappdata(Ax,'xLimAdjust',true);
    if true % ##### MOSW
        peer = getappdata(Ax,'graphicsPlotyyPeer');
    else
        peer = [];
        try
            peer = get(Ax,'__plotyy_axes__');
        end
        peer = peer(peer ~= Ax);
    end
    if ~isempty(peer)
        setappdata(peer,'xLimAdjust',true);
    end
end

% `Time` can be `NaN` when the input tseries is empty.
try
    isTimeNan = isequaln(Time,NaN);
catch %#ok<CTCH>
    % Old syntax.
    isTimeNan = isequalwithequalnans(Time,NaN); %#ok<FPARK>
end

% Set up the x-axis with proper dates. Do not do this if `time` is NaN,
% which happens with empty tseries.
if isTimeAxis && ~isTimeNan
    setappdata(Ax,'tseries',true);
    setappdata(Ax,'freq',Freq);
    setappdata(Ax,'range',Rng);
    setappdata(Ax,'datePosition',opt.dateposition);
    mydatxtick(Ax,Rng,Time,Freq,UsrRng,opt);
end

% Perform user supplied function.
if ~isempty(opt.function)
    opt.function(H);
end

% Make the y-axis tight.
if opt.tight
    grfun.yaxistight(h);
end

% Datatip cursor
%----------------
% Store the dates within each plotted object for later retrieval by
% datatip cursor.
for ih = H(:).'
    setappdata(ih,'dateLine',Rng);
end

if true % ##### MOSW
    % Use IRIS datatip cursor function in this figure; in `utils.datacursor',
    % we also handle cases where the current figure includes both tseries and
    % non-tseries graphs.
    obj = datacursormode(gcf());
    set(obj,'UpdateFcn',@utils.datacursor);
else
    % Do nothing.
end


% Nested functions...


%**************************************************************************


    function Range = doMergeRange(Range,Comprise)
        first = dec2dat(Comprise(1),Freq,opt.dateposition);
        % Make sure ranges with different frequencies are merged
        % properly.
        while dat2dec(first-1,opt.dateposition) > Comprise(1)
            first = first - 1;
        end
        last = dec2dat(Comprise(end),Freq,opt.dateposition);
        while dat2dec(last+1,opt.dateposition) < Comprise(end)
            last = last + 1;
        end
        Range = min(Range(1),first) : max(Range(end),last);
    end % doMergeRange()


%**************************************************************************


    function doPlot()
        FuncStr = Func;
        if isfunc(FuncStr)
            FuncStr = func2str(FuncStr);
        end
        switch FuncStr
            case {'scatter'}
                if nx ~= 2
                    utils.error('tseries:myplot', ...
                        ['Scatter plot input data must have ', ...
                        'exactly two columns.']);
                end
                H = scatter(Ax,Data(:,1),Data(:,2),plotSpecs{:});
                if ~isempty(varargin)
                    set(H,varargin{:});
                end
                isTimeAxis = false;
            case {'barcon'}
                % Do not pass `plotspecs` but do pass user options.
                [H,varargout{1}] ...
                    = tseries.mybarcon(Ax,Time,Data,varargin{:});
                isTimeAxis = true;
            otherwise
                DataInf = grfun.myreplacenancols(Data,Inf);
                H = feval(Func,Ax,Time,DataInf,plotSpecs{:});
                if ~isempty(varargin)
                    set(H,varargin{:});
                end
                isTimeAxis = true;
        end
    end % doPlot()


end

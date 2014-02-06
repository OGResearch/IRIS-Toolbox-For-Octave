function [H,Range,Data,Time,UserRange,Freq,varargout] ...
    = myplot(Func,varargin)
% myplot  [Not a public function] Master plot function for tseries objects.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

% If the caller supplies empty `Func`, the graph will not be actually
% rendered. This is a dry call to `myplot` used from within `plotyy`.

% User-specified handle to axes. Otherwise, the gca will be used. Make
% sure this complies with future Matlab graphics implementation where
% handles will no longer be numerics.
if length(varargin{1}) == 1 && ishghandle(varargin{1})
    Ax = varargin{1}(1);
    varargin(1) = [];
else
    Ax = gca();
end

% User-defined range. Otherwise the entire range of the tseries object
% will be plotted. A cell array is passed in by the `plotyy` function to
% also indicate the other axes' range that must be comprised by the current
% one.
if isnumeric(varargin{1})
    comprise = [];
    Range = varargin{1};
    varargin(1) = [];
elseif iscell(varargin{1}) && length(varargin{1}) == 2 ...
        && all(cellfun(@isnumeric,varargin{1}))
    comprise = varargin{1}{2};
    Range = varargin{1}{1};
    varargin(1) = [];
else
    comprise = [];
    Range = Inf;
end

UserRange = Range;

% Tseries object that will be plotted.
X = varargin{1};
varargin(1) = [];

X = resize(X,Range);

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
    error('Incorrect type of input argument(s).');
end

%--------------------------------------------------------------------------

X.data = X.data(:,:);
[~,nx] = size(X.data);
Range = specrange(X,Range);

H = [];
if isempty(Range)
    warning('iris:tseries', ...
        'No graph displayed because date range is empty.');
    return
end

Freq = datfreq(Range(1));

% Original x-axis limits.
if isequal(getappdata(Ax,'xLimAdjust'),true)
    xLim0 = getappdata(Ax,'trueXLim');
else
    xLim0 = get(Ax,'xLim');
end

% If hold==on, make sure the new range comprises thes existing dates if
% the existing graph is a tseries graph.
if ~isempty(Func) ...
        && ~isempty(Range) && strcmp(get(Ax,'nextPlot'),'add') ...
        && isequal(getappdata(Ax,'tseries'),true)
    Range = doMergeRange(Range([1,end]),xLim0);
end

% Make sure the new range and `userrange` both comprise the `comprise`
% dates; this is used in `plotyy`.
if ~isempty(comprise)
    Range = doMergeRange(Range,comprise);
    if ~isequal(UserRange,Inf)
        UserRange = doMergeRange(UserRange,comprise);
    end
end

Data = mygetdata(X,Range);
Time = dat2grid(Range,opt.dateposition);

if isempty(Func)
    return
end

if isfunc(Func)
    funcAsChar = func2str(Func);
elseif ischar(Func) || iscellstr(Func)
    funcAsChar = char(Func);
else
    funcAsChar = '';
end

% Do the actual plot.
set(Ax,'xTickMode','auto','xTickLabelMode','auto');
H = [];
doPlot();

if isequal(opt.xlimmargin,true) ...
        || (ischar(opt.xlimmargin) ...
        && strcmpi(opt.xlimmargin,'auto') ...
        && any(strcmp(funcAsChar,{'bar','barcon'})))
    setappdata(Ax,'xLimAdjust',true);
    peer = getappdata(Ax,'graphicsPlotyyPeer');
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
    mydatxtick(Ax,Time,Freq,UserRange,opt);
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
    setappdata(ih,'dateLine',Range);
end

% Use IRIS datatip cursor function in this figure; in `utils.datacursor',
% we also handle cases where the current figure includes both tseries and
% non-tseries graphs.
if ismatlab
    obj = datacursormode(gcf());
    set(obj,'UpdateFcn',@utils.datacursor);
end

% Nested functions.

%**************************************************************************
    function range = doMergeRange(range,comprise)
        first = grid2dat(comprise(1),Freq,opt.dateposition);
        % Make sure ranges with different frequencies are merged
        % properly.
        while dat2grid(first-1,opt.dateposition) > comprise(1)
            first = first - 1;
        end
        last = grid2dat(comprise(end),Freq,opt.dateposition);
        while dat2grid(last+1,opt.dateposition) < comprise(end)
            last = last + 1;
        end
        range = min(range(1),first) : max(range(end),last);
    end % doMergeRange().

%**************************************************************************
    function doPlot()
        switch funcAsChar
            case {'scatter'}
                if nx ~= 2
                    utils.error('tseries', ...
                        'Scatter plot input data must have exactly two columns.');
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
                H = Func(Ax,Time,DataInf,plotSpecs{:});
                if ~isempty(varargin)
                    set(H,varargin{:});
                end
                isTimeAxis = true;
        end
    end % doPlot().

end

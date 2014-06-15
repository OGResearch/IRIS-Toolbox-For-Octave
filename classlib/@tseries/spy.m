function [Ax,Li] = spy(varargin)
% spy  Visualise tseries observations that pass a test.
%
% Syntax
% =======
%
%     [AA,LL] = spy(X,...)
%     [AA,LL] = spy(RANGE,X,...)
%
% Input arguments
% ================
%
% * `X` [ tseries ] - Input tseries object whose non-NaN observations will
% be plotted as markers.
%
% * `RANGE` [ tseries ] - Date range on which the tseries observations will
% be visualised; if not specified the entire available range will be used.
%
% Output arguments
% =================
%
% * `AA` [ tseries ] - Handle to the axes created.
%
% * `LL` [ tseries ] - Handle to the marks plotted.
%
% Options
% ========
%
% * `'names='` [ cellstr ] - Names that will be used to annotate individual
% columns of the input tseries object.
%
% * `'test='` [ function_handle | *@(x)~isnan(x)* ] - Test applied to each
% observations; only the values returning a true will be displayed.
%
% See help on [`tseries/plot`](tseries/plot) and the built-in function
% `spy` for all options available.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

if all(ishghandle(varargin{1})) ...
        && strcmpi(get(varargin{1}(1),'type'),'axes')
    Ax = varargin{1}(1);
    varargin(1) = [];
else
    Ax = gca();
end

if isnumeric(varargin{1})
    range = varargin{1};
    varargin(1) = [];
else
    range = Inf;
end

X = varargin{1};
varargin(1) = [];

% Parse input arguments.
P = inputParser();
if ismatlab
P.addRequired('range',@isnumeric);
P.addRequired('x',@(x) isa(x,'tseries'));
P.parse(range,X);
else
P = P.addRequired('range',@isnumeric);
P = P.addRequired('x',@(x) isa(x,'tseries'));
P = P.parse(range,X);
end

% Parse options.
[opt,varargin] = passvalopt('tseries.spy',varargin{:});
freq = get(X,'freq');

%--------------------------------------------------------------------------

[x,range] = rangedata(X,range);
x = x(:,:,1);
x = opt.test(x.');
if ~islogical(x)
    x = logical(x);
end
time = dat2dec(range,'centre');
xCoor = repmat(1 : size(x,2),size(x,1),1);
xCoor = time(xCoor);
yCoor = repmat(1 : size(x,1),1,size(x,2));
Li = plot(Ax,xCoor(x),yCoor(x),'lineStyle','none','marker','.');
set(gca(),'YDir','reverse','yLim',[0,size(x,1)+1], ...
    'xLim',[xCoor(1)-0.5,xCoor(end)+0.5]);

setappdata(Ax,'tseries',true);
setappdata(Ax,'freq',freq);
setappdata(Ax,'xLimAdjust',true);
mydatxtick(Ax,range,time,freq,range,opt);

set(Ax,'gridLineStyle',':');
yLim = [1,size(x,1)];
if ~isempty(opt.names)
    set(Ax,'yTick',yLim(1):yLim(end),'yTickMode','manual', ...
        'yTickLabel',opt.names,'yTickLabelMode','manual', ...
        'yLim',[0.5,yLim(end)+0.5],'yLimMode','manual');
else
    yTick = get(Ax,'yTick');
    yTick(yTick < 1) = [];
    yTick(yTick > size(x,1)) = [];
    set(Ax,'yTick',yTick,'yTickMode','manual');
end

xlabel('');
set(Li,varargin{:});

end
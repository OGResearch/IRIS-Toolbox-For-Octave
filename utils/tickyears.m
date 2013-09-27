function tickyears(varargin)
% tickyears  Year-based grid on X axis.
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

if ~isempty(varargin) && all(ishghandle(varargin{1}))
    h = varargin{1};
    varargin(1) = [];
else
    h = gca();
end

if ~isempty(varargin)
    n = varargin{1};
else
    n = 1;
end

%--------------------------------------------------------------------------

for ih = h(:).'
    if isempty(getappdata(ih,'plotyy'))
        iHandle = ih;
    else
        iHandle = getappdata(ih,'plotyy');
    end
    xLim = get(iHandle,'xLim');
    xTick = floor(xLim(1)) : n : ceil(xLim(end));
    set(iHandle,...
        'xLim',xTick([1,end]),...
        'xLimMode','manual',...
        'xTick',xTick,...
        'xTickMode','manual',...
        'xTickLabelMode','auto');
end

end

function clicktocopy(ax)
% clicktocopy  Axes will expand in a new window when clicked on.
%
% Syntax
% =======
%
%     grfun.clicktocopy(h)
%
% Input arguments
% ================
%
% * `h` [ numeric ] - Handle to axes objects that will be added a Button
% Down callback opening them in a new window on mouse click.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

% Parse input arguments.
pp = inputParser();
if ismatlab
    pp.addRequired('h',@(x) all(ishghandle(x)) ...
       && all(strcmp(get(x,'type'),'axes')));
else
    pp = pp.addRequired('h',@(x) all(ishghandle(x)) ...
       && all(strcmp(get(x,'type'),'axes')));
end   

%--------------------------------------------------------------------------

set(ax,'buttonDownFcn',@xxCopyAxes);
h = findobj(ax,'tag','highlight');
set(h,'buttonDownFcn',@xxCopyAxes);
h = findobj(ax,'tag','vline');
set(h,'buttonDownFcn',@xxCopyAxes);

end

%**************************************************************************
function xxCopyAxes(h,varargin)
    if ~isequal(get(h,'type'),'axes')
      h = get(h,'parent');
    end
    if ~ismatlab
        kids = findall(h,'-property','userdata');
        toShow = arrayfun(@(x)isfield(get(x,'userData'),'notInLegend'),kids);
        set(kids(toShow),'handleVisibility','on');
    end
    new = copyobj(h,figure());
    if ~ismatlab
        newKids = findall(new,'-property','userdata');
        toHide = arrayfun(@(x)isfield(get(x,'userData'),'notInLegend'),newKids);
        set(kids(toShow),'handleVisibility','off');
        set(newKids(toHide),'handleVisibility','off');
    end
    set(new, ...
      'position',[0.1300,0.1100,0.7750,0.8150], ...
      'units','normalized', ...
      'buttonDownFcn','');
    end
    % xxCopyAxes().

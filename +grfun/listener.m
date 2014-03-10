function Ls = listener(Leader,Follower,Name,varargin)
% listener  [Not a public function] Add listeners to IRIS graphics objects.
%
% Backed IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

if is.hg2()
    listenerFcn = @event.proplistener;
    postSetStr = 'PostSet';
else
    listenerFcn = @handle.listener;
    postSetStr = 'PropertyPostSet';
end

% Convert graphics handle to graphics object.
leaderObj = handle(Leader);

switch lower(Name)
    
    case 'highlight'
        Ls = listenerFcn(leaderObj, ...
            findprop(leaderObj,'YLim'),...
            postSetStr, ...
            @(obj,evd)(xxHighlight(obj,evd,Leader,Follower)));

    case 'vline'
        Ls = listenerFcn(leaderObj, ...
            findprop(leaderObj,'YLim'),...
            postSetStr, ...
            @(obj,evd)(xxVLine(obj,evd,Leader,Follower)));

    case {'hline','zeroline'}
        Ls = listenerFcn(leaderObj, ...
            findprop(leaderObj,'XLim'),...
            postSetStr, ...
            @(obj,evd)(xxHLine(obj,evd,Leader,Follower)));
        
    case 'caption'
        Ls = listenerFcn(leaderObj, ...
            findprop(leaderObj,'YLim'),...
            postSetStr, ...
            @(obj,evd)(xxCaption(obj,evd,Leader,Follower,varargin{1})));

end

% Make sure the listener object persists.
setappdata(Follower,[Name,'Listener'],Ls);

end


% Subfunctions...


%**************************************************************************
function xxHighlight(Obj,Evd,Ax,Pt) %#ok<INUSL>
    y = get(Ax,'yLim');
    set(Pt,'yData',[y(1),y(1),y(2),y(2),y(1)]);
end % xxHighlight()


%**************************************************************************
function xxVLine(Obj,Evd,Ax,Ln) %#ok<INUSL>
    y = get(Ax,'yLim');
    set(Ln,'yData',y);
end % xxVLine()


%**************************************************************************
function xxHLine(Obj,Evd,Ax,Ln) %#ok<INUSL>
    x = get(Ax,'xLim');
    set(Ln,'xData',x);
end % xxHLine()


%**************************************************************************
function xxCaption(Obj,Evd,Ax,Cp,K) %#ok<INUSL>
    yLim = get(Ax,'yLim');
    ySpan = yLim(end) - yLim(1);
    pos = get(Cp,'position');
    pos(2) = yLim(1) + K*ySpan;
    set(Cp,'position',pos);
end % xxCaption()

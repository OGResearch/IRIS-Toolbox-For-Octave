function Ls = listener(Leader,Follower,Name,varargin)
% listener  [Not a public function] Add listeners to IRIS graphics objects.
%
% Backed IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

% Choose the appropriate listener function.
if ismatlab
    if is.hg2()
        listenerFcn = @(h,prop,pEvent,fun) event.proplistener(h,findprop(h,prop),pEvent,fun);
        postSetStr = 'PostSet';
    else
        listenerFcn = @(h,prop,pEvent,fun) handle.listener(h,findprop(h,prop),pEvent,fun);
        postSetStr = 'PropertyPostSet';
    end
    % Convert graphics handle to graphics object.
    leaderObj = handle(Leader);
else
    listenerFcn = @(h,prop,dummy,fun) addlistener(h,prop,fun);
    leaderObj = Leader;
    postSetStr = '';
end

switch lower(Name)
    
    case 'highlight'
        listenerFcn(leaderObj, ...
            'YLim',...
            postSetStr, ...
            @(obj,evd)(xxHighlight(obj,evd,Leader,Follower)));

    case 'vline'
        listenerFcn(leaderObj, ...
            'YLim',...
            postSetStr, ...
            @(obj,evd)(xxVLine(obj,evd,Leader,Follower)));

    case {'hline','zeroline'}
        listenerFcn(leaderObj, ...
            'XLim',...
            postSetStr, ...
            @(obj,evd)(xxHLine(obj,evd,Leader,Follower)));
        
    case 'caption'
        listenerFcn(leaderObj, ...
            'YLim',...
            postSetStr, ...
            @(obj,evd)(xxCaption(obj,evd,Leader,Follower,varargin{1})));

end

% Make sure the listener object persists.
try %#ok<TRYNC>
    Ls = ans;
    setappdata(Follower,[Name,'Listener'],Ls);
end

end


% Subfunctions...


%**************************************************************************
function xxHighlight(Obj,Evd,Ax,Pt) %#ok<INUSL>
    y = get(Ax,'yLim');
    oldYData = get(Pt,'yData');
    newYData = [y(1),y(1),y(2),y(2),y(1)];
    set(Pt,'yData',newYData(1:length(oldYData)));
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

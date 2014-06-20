function Ls = listener(Leader,Follower,Name,varargin)
% listener  [Not a public function] Add listeners to IRIS graphics objects.
%
% Backed IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

% Choose the appropriate listener function.
if is.matlab % ##### MOSW
    if is.hg2()
        listenerFcn = @(h,prop,pEvent,fun) event.proplistener(h,findprop(h,prop),pEvent,fun);
        postSetStr = 'PostSet';
    else
        listenerFcn = @(h,prop,pEvent,fun) handle.listener(h,findprop(h,prop),pEvent,fun);
        postSetStr = 'PropertyPostSet';
    end
else
    listenerFcn = @(h,prop,dummy,fun) addlistener(h,prop,fun);
    postSetStr = '';
end

% Convert graphics handle to graphics object.
leaderObj = handle(Leader);

switch lower(Name)
    
    case 'highlight'
       listenerFcn(leaderObj, ...
           'YLim',...
           postSetStr, ...
           @(obj,evd)(xxHighlight(obj,evd,Leader,Follower)));
    
    case 'infline'
       listenerFcn(leaderObj, ...
           [varargin{1} 'Lim'],...
           postSetStr, ...
           @(obj,evd)(xxInfLine(obj,evd,Leader,Follower,varargin{1})));
       
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
  if ~is.matlab % ##### MOSW
    y = get(Ax,'yLim');
    if isinf(y(1))
        y(1) = -realmax();
    end
    if isinf(y(2))
        y(2) = realmax();
    end
    oldYData = get(Pt,'yData');
    newYData = [y(1),y(1),y(2),y(2),y(1)];
    set(Pt,'yData',newYData(1:length(oldYData)));
  end
end % xxHighlight()


%**************************************************************************
function xxInfLine(Obj,Evd,Ax,Pt,xy) %#ok<INUSL>
  if ~is.matlab % ##### MOSW
    axlim = get(Ax,[xy 'Lim']);
    oldData = get(Pt,[xy 'Data']);
    newData = [axlim(1),axlim(1),axlim(2),axlim(2),axlim(1)];
    set(Pt,[xy 'Data'],newData(1:length(oldData)));
  end
end % xxInfLine()


%**************************************************************************


function xxCaption(Obj,Evd,Ax,Cp,K) %#ok<INUSL>
    yLim = get(Ax,'yLim');
    ySpan = yLim(end) - yLim(1);
    pos = get(Cp,'position');
    pos(2) = yLim(1) + K*ySpan;
    set(Cp,'position',pos);
end % xxCaption()

function h = mycaption(ax,location,caption,vPosition,hPosition)
% mycaption  [Not a public function] Place text caption at the edge of an annotating object.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

% Horizontal position and alignment.
inside = length(location) > 1;
switch lower(hPosition)
   case 'left'
      if inside
         hAlign = 'left';
      else
         hAlign = 'right';
      end
      x = location(1);
   case 'right'
      if inside
         hAlign = 'right';
      else
         hAlign = 'left';
      end
      x = location(end);
   otherwise
      hAlign = 'center';
      x = (location(1) + location(end))/2;
end

% Vertical position and alignment.
ylim = get(ax,'yLim');
yspan = ylim(end) - ylim(1);
switch lower(vPosition)
   case 'top'
      y = 0.98;
      vAlign = 'top';
   case 'bottom'
      y = 0.02;
      vAlign = 'bottom';
   case {'centre','center','middle'}
      y = 0.5;
      vAlign = 'middle';
   otherwise
      y = vPosition;
      vAlign = 'middle';
end

h = text(x,ylim(1)+y*yspan,caption, ...
   'color',[0,0,0], ...
   'verticalAlignment',vAlign, ...
   'horizontalAlignment',hAlign);

% Update caption y-position whenever the parent y-lims change.
grfun.listener(ax,h,'caption',y);

end
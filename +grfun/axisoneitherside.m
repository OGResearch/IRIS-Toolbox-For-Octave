function ax = axisoneitherside(varargin)
% axisoneitherside  Show x-axis and/or y-axis on either side of a graph.
%
% Syntax
% =======
%
%     aa = grfun.axisoneitherside()
%     aa = grfun.axisoneitherside(aa)
%     aa = grfun.axisoneitherside(spec)
%     aa = grfun.axisoneitherside(aa,spec)
%
% Input arguments
% ================
%
% * `aa` [ numeric ] - Handle to the axes that will be changed.
%
% * `spec` [ 'x' | 'y' | 'xy' ] - Specification which axis or axes to show
% on either side of the graph.
%
% Output arguments
% =================
%
% * `aa` [ numeric ] - Handle to the axes changed.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

if ~isempty(varargin) && isnumeric(varargin{1})
   ax = varargin{1};
   varargin(1) = [];
else   
   ax = gca();
end
if ~isempty(varargin)
   option = lower(strtrim(varargin{1}));
   varargin(1) = [];
else
   option = 'xy';
end
nax = numel(ax);
if nax > 1
   ax2 = nan([2,nax]);
   for i = 1 : numel(ax)
      ax2(:,i) = yaxisboth(ax(i),option);
   end
   ax = ax2;
   return
end

xaxis = ~isempty(strfind(option,'x'));
yaxis = ~isempty(strfind(option,'y'));

%**************************************************************************

ax2 = getappdata(ax,'axisOnEitherSide');
if isempty(ax2)
   keepTheOther = false;
   % Temporary show excluded from legend (for Octave's way of excluding)
   if ~ismatlab
       grfun.mytrigexcludedfromlegend(ax,'on');
   end
   pa = get(ax,'parent');
   ax2 = copyobj(ax,pa);
   % Swap the two axes in the list of children to make sure the one with
   % the data is sits on top.
   ch = get(pa,'children');
   index1 = find(ch == ax);
   index2 = find(ch == ax2);
   [ch(index1),ch(index2)] = deal(ch(index2),ch(index1));
   set(pa,'children',ch);
   setappdata(ax,'axisOnEitherSide',ax2);
   % Hide back excluded from legend (for Octave's way of excluding)
   if ~ismatlab
       grfun.mytrigexcludedfromlegend(ax,'off');
       grfun.mytrigexcludedfromlegend(ax2,'off');
   end
else
   keepTheOther = true;
end

cla(ax2);
set(ax2,'xGrid','off','yGrid','off');
pn = {'*TickLabel','*TickLabelMode','*Tick','*TickMode'};
pnx = strrep(pn,'*','x');
pny = strrep(pn,'*','y');
pvoff = {'','manual',[],'manual'};
if xaxis
   set(ax2,pnx,get(ax,pnx));
   set(ax2,'xAxisLocation','top');
elseif ~keepTheOther
   set(ax2,pnx,pvoff);
end
if yaxis
   set(ax2,pny,get(ax,pny));
   set(ax2,'yAxisLocation','right');
elseif ~keepTheOther
   set(ax2,pny,pvoff);
end

ax = [ax;ax2];
try % not implemented in Octave
    linkaxes(ax,option);
end

end
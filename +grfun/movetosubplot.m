function Ax = movetosubplot(Ax,varargin)
% movetosubplot  Move an existing axes object or legend to specified subplot position.
%
% Syntax
% =======
%
%     Ax = movetosubplot(Ax,M,N,P)
%
% Input arguments
% ================
%
% * `Ax` [ numeric ] - Handle to an existing axes object or legend.
%
% * `M`, `N`, `P` [ numeric ] - Specification of the new position; see help
% on standard `subplot`.
%
% Output arguments
% =================
%
% * `AX` [ numeric ] - Handle to the axes or legend moved to the new
% position.
%
% Description
% ============
%
% Example
% ========


% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

oldPos = get(Ax,'position');
Fig = get(Ax,'parent');
set(Fig,'units','normalized');

if ischar(varargin{1})
    switch varargin{1}
        case 'bottom'
            bottomPos = 0; %0.01;
            newPos = [0.5-oldPos(3)/2,bottomPos,oldPos(3:4)];
        case 'top'
            topPos = 1; %0.98;
            newPos = [0.5-oldPos(3)/2,topPos-oldPos(4),oldPos(3:4)];
    end
else
    helperAx = subplot(varargin{:},'visible','off');
    newPos = get(helperAx,'position');
    %close(helperFig);
    delete(helperAx);
    if isequal(get(Ax,'tag'),'legend')
        newPos(1) = newPos(1) + (newPos(3) - oldPos(3))/2;
        newPos(2) = newPos(2) + (newPos(4) - oldPos(4))/2;
        newPos(3:4) = oldPos(3:4);
    end
end

set(Ax,'position',newPos);

end
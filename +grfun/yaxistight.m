function yaxistight(varargin)
% yaxistight  Make y-axis tight.
%
% Syntax
% =======
%
%     grfun.yaxistight(Ax)
%
% Input arguments
% ================
%
% * `Ax` [ numeric ] - Handles to axes objects whose vertical axes will be
% made tight.
%
% Description
% ============
%
% Behaviour of `grfun.yaxistight` differs from the standard function `axis`
% in that it disregards `grfun.vline`, `grfun.zeroline` and
% `grfun.highlight` objects when determining the minimum and maximum on the
% vertical axis.
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

    if ~isempty(varargin) && all(ishghandle(varargin{1}))
        Ax = varargin{1}(:).';
        varargin(1) = []; %#ok<NASGU>
    else
        Ax = gca();
    end
    
%--------------------------------------------------------------------------

    for iAx = Ax
        
        ch = findobj(iAx,'-not','tag','highlight', ...
            '-and','-not','tag','vline', ...
            '-and','-not','tag','hline', ...
            '-and','-not','tag','zeroline');
        lim = objbounds(ch);
        if isempty(lim)
            ylim = get(iAx,'yLim');
        else
            ylim = lim(3:4);
        end
        
        if any(~isinf(ylim)) && ylim(1) < ylim(2)
            set(iAx,'yLim',ylim,'yLimMode','manual');
        end
        
    end
    
end
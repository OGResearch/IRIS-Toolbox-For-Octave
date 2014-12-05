function This = myplot(This)
% myplot  [Not a public function] Plot userfigureobj object.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

if This.options.visible
    visibleFlag = 'on';
else
    visibleFlag = 'off';
end

%--------------------------------------------------------------------------

This = myplot@report.basefigureobj(This);

% Re-create the figure whose handle was captured at the
% time the figure constructor was called.
if ~isempty(This.savefig)
    figFile = [mosw.tempname(pwd()),'.fig'];
    fid = fopen(figFile,'w+');
    fwrite(fid,This.savefig);
    fclose(fid);
    h = hgload(figFile);
    set(h,'visible',visibleFlag);
    delete(figFile);
    This.handle = h;
    if true % ##### MOSW
        % Matlab only
        %-------------
        % Do nothing.
    else
        % Octave only
        %-------------
        a = findobj(h,'type','axes'); %#ok<UNRCH>
        if ~isempty(a)
            xLimMode = getappdata(h,'xLimMode');
            yLimMode = getappdata(h,'yLimMode');
            zLimMode = getappdata(h,'zLimMode');
            set(a, ...
                'xLimMode',xLimMode, ...
                'yLimMode',yLimMode, ...
                'zLimMode',zLimMode);
        end
    end
end

end

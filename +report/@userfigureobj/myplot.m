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
    figFile = [tempname(pwd()),'.fig'];
    fid = fopen(figFile,'w+');
    fwrite(fid,This.savefig);
    fclose(fid);
    This.handle = myloadfig(This,figFile);
    set(This.handle,'visible',visibleFlag);
    delete(figFile);
end

end

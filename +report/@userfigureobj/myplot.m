function This = myplot(This)
% myplot  [Not a public function] Plot userfigureobj object.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

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
    fid = fopen(This.figfile,'w+');
    fwrite(fid,This.savefig);
    fclose(fid);
    This.handle = open(This.figfile);
    set(This.handle,'visible',visibleFlag);
    delete(This.figfile);
end

end
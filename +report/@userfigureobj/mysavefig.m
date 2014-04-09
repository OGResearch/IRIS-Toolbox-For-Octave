function mysavefig(This,hFig,figFile)
% mysavefig  [Not a public function] Save figure to a binary file.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

kids = findall(hFig,'-property','userdata');
toShow = arrayfun(@(x)isfield(get(x,'userData'),'notInLegend'),kids);
set(kids(toShow),'handleVisibility','on');

hgsave(hFig,figFile,'-v7');

end
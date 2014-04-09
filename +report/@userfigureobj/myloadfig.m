function hFig = myloadfig(This,figFile)
% myloadfig  [Not a public function] Load figure from a binary file.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

hFig = hgload(figFile);

kids = findall(hFig,'-property','userdata');
toHide = arrayfun(@(x)isfield(get(x,'userData'),'notInLegend'),kids);
set(kids(toHide),'handleVisibility','off');

end
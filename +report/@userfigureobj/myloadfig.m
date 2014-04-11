function hFig = myloadfig(This,figFile)
% myloadfig  [Not a public function] Load figure from a binary file.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

hFig = hgload(figFile);
% Hide excluded from legend (for Octave's way of excluding)
if ~ismatlab
    grfun.mytrigexcludedfromlegend(hFig,'off');
end

end
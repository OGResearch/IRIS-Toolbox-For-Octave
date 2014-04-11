function mysavefig(This,hFig,figFile)
% mysavefig  [Not a public function] Save figure to a binary file.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

% Temporary show excluded from legend (for Octave's way of excluding)
if ~ismatlab
    grfun.mytrigexcludedfromlegend(hFig,'on');
end
hgsave(hFig,figFile,'-v7');
% Hide back excluded from legend (for Octave's way of excluding)
if ~ismatlab
    grfun.mytrigexcludedfromlegend(hFig,'off');
end

end
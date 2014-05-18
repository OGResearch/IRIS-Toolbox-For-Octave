function mysavefig(This,hFig,figFile)
% mysavefig  [Not a public function] Save figure to a binary file.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

if ~ismatlab
    % Temporary show excluded from legend (for Octave's way of excluding)
    grfun.mytrigexcludedfromlegend(hFig,'on');
    % set x/ylimmode to 'manual' to avoid their adjustment when loading from file
    hAx = findobj(hFig,'type','axes','-not','tag','legend');
    set(hAx,{'xlimmode'},'manual',{'ylimmode'},'manual');
end
% save figure to a file
hgsave(hFig,figFile,'-v7');
% Hide back excluded from legend (for Octave's way of excluding)
if ~ismatlab
    grfun.mytrigexcludedfromlegend(hFig,'off');
end

end
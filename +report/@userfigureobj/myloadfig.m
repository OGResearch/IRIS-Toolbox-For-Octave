function hFig = myloadfig(This,figFile)
% myloadfig  [Not a public function] Load figure from a binary file.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

hFig = hgload(figFile);

if ~ismatlab
    % add all the listeners back to highlight, vline, hline and zeroline objects
    tags = {'highlight', 'vline', 'hline', 'zeroline', 'highlight-caption', ...
        'vline-caption'};
    for tix = 1 : numel(tags)
        hTmp = findobj(hFig,'tag',tags{tix});
        for hix = hTmp'
            par = ancestor(hix,'axes');
            listId = regexprep(tags{tix},'.*-(caption)','$1');
            grfun.listener(hix,par,listId);
        end
    end
    % Hide excluded from legend (for Octave's way of excluding)
    grfun.mytrigexcludedfromlegend(hFig,'off');
end

end
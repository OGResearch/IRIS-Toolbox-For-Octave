function hTrig = mytrigexcludedfromlegend(h,stat)

hTrig = [];
for ih = h(:)
    kids = findall(ih);
    toTrig = isappdata(kids,'notInLegend');
    hTrig = [hTrig kids(toTrig)];
end

if ~isempty(hTrig)
    pStat = {'on','off'};
    if nargin < 2 || ~any(strcmpi(stat,pStat))
        ix = strcmpi(get(hTrig(1),'handleVisibility'),pStat{1}) + 1;
        stat = pStat{ix};
    end
    set(hTrig,{'handleVisibility'},stat);
end

end
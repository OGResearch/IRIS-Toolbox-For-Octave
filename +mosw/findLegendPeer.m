function legH = findLegendPeer(Ax)

legH = nan;

leg = findobj(get(Ax,'parent'),'tag','legend');

for ix = leg(:)
    udata = get(ix,'userdata');
    if isa(udata,'struct') && isfield(udata,'handle') && udata.handle == Ax
        legH = ix;
        break
    end
end

end

function lims = myobjbounds(this)

try
    lims = objbounds(this);
catch
    xlim = nan(1,2);
    ylim = nan(1,2);
    
    types = get(this,'type');
    
    if ischar(types)
        types = {types};
    end
    
    [this,types] = xxReplaceAxesWithKids(this,types);
    
    for ix = 1:numel(types)
        switch types{ix}
            case {'line', 'surface'}
                if strcmpi(get(this(ix),'xliminclude'),'on')
                    xData = get(this(ix), 'xData');
                else
                    xData = NaN;
                end
                if strcmpi(get(this(ix),'yliminclude'),'on')
                    yData = get(this(ix), 'yData');
                else
                    yData = NaN;
                end
            case 'patch'
                xyData = get(this(ix), 'vertices');
                fcs = get(this(ix), 'faces');
                xyData = xyData(fcs(isfinite(fcs)),:);
                if strcmpi(get(this(ix),'xliminclude'),'on')
                    xData = xyData(:,1);
                else
                    xData = NaN;
                end
                if strcmpi(get(this(ix),'yliminclude'),'on')
                    yData = xyData(:,2);
                else
                    yData = NaN;
                end
            otherwise
                xData = NaN;
                yData = NaN;
        end
        
        xlim = [min(xlim(1), min(xData)),max(xlim(2), max(xData))];
        ylim = [min(ylim(1), min(yData)),max(ylim(2), max(yData))];
    end
    
    lims = [xlim, ylim, 0, 0];
end

end

function [this,types] = xxReplaceAxesWithKids(this,types)
    axIx = strcmpi(types,'axes');
    if all(~axIx)
        return
    end
    newKids = [];
    newTypes = [];
    for ix = find(axIx)
        allObj = findobj(this(ix));
        newKids = [newKids;allObj(2:end)];
        newTypes = get(newKids,'type');
        [newKids,newTypes] = xxReplaceAxesWithKids(newKids,newTypes);
    end
    this = [this(~axIx);newKids];
    types = [types(~axIx);newTypes];
end
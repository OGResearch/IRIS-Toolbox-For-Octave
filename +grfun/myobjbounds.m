function lims = myobjbounds(this)

try
    lims = objbounds(this);
catch
    xlim = nan(1,2);
    ylim = nan(1,2);
    
    types = get(this,'type');
    
    for ix = 1:numel(types)
        switch types{ix}
            case {'line', 'surface'}
                xData = get(this(ix), 'xData');
                yData = get(this(ix), 'yData');
                
            case 'patch'
                xyData = get(this(ix), 'vertices');
                fcs = get(this(ix), 'faces');
                xyData = xyData(fcs(isfinite(fcs)),:);
                xData = xyData(:,1);
                yData = xyData(:,2);
            otherwise
                xData = nan;
                yData = nan;
        end
        
        xlim = [min(xlim(1), min(xData)),max(xlim(2), max(xData))];
        ylim = [min(ylim(1), min(yData)),max(ylim(2), max(yData))];
    end
    
    lims = [xlim, ylim, 0, 0];
end

end
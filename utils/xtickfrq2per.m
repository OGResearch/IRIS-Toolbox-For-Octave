function xtickfrq2per(h,format)
    
    if ~exist('h','var')
        h = gca();
    end
    
    if ~exist('format','var')
        format = '%.1f';
    end
    
    xtick = 2*pi./get(h,'xtick');
    n  = length(xtick);
    xticklabel = cell(1,n);
    for i = 1 : n
        xticklabel{i} = sprintf(format,xtick(i));
    end
    set(h,'xticklabel',xticklabel,'xtickmode','manual');
    
end
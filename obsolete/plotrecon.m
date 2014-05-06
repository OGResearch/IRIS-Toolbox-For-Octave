function [ax,chksum] = plotrecon(d,plotrng,varargin)
    
    % get panel definitions
    define = varargin(1:3);
    varargin(1:3) = [];
    
    default = {...
        'dateformat','YYYY:P',@ischar,...
        'grid',true,@islogical,...
        'highlight',[],@(x) isnumeric(x) || isempty(x),...
        'panels',[1,2,3],@isnumeric,...
        'title','',@(x) ischar(x) || isempty(x),...
        'warning',true,@islogical,...
        };
    options = passvalopt(default,varargin{:});
    
%**************************************************************************
    
    options.panels = unique(options.panels);
    npanel = length(options.panels);
    
    tol = getrealsmall();
    
    % Get expressions and labels.
    for i = 1 : 3
        [expr{i},label{i}] = strfun.charlist2cellstr(define{i});
        if ~isempty(expr{i})
            index = cellfun(@isempty,label{i});
            label{i}(index) = expr{i}(index);
        end
    end
    expr = [expr{:}];
    label = [label{:}];
    
    % evaluate all series
    n = length(expr);
    [x{1:n}] = dbeval(d,expr{:});
    x(~cellfun(@(isArg)is.tseries(isArg),x)) = {tseries()};
    
    % compute remainder (*) if requested
    starindex = find(strcmp('*',expr));
    if length(starindex) > 1 || (length(starindex) == 1 && starindex == 1)
        error('Invalid use of asterisk.');
    elseif ~isempty(starindex)
        index = 1 : n;
        index([1,starindex]) = [];
        x{starindex} = x{1} - sum([x{index}],2);
    end
    
    % handles to axes
    ax = [];
    
    pos = 1;
    
    if any(options.panels == 1)
        % headline panel
        subplot(npanel,1,pos);
        bar(plotrng,x{1},'dateformat',options.dateformat);
        title(label{1}); %,'fontsize',12,'fontweight','bold');
        ax(end+1) = gca();
        pos = pos + 1;
    end
    
    % contributions panel
    if any(options.panels == 2)
        subplot(npanel,1,pos);
        bar(plotrng,[x{2:end-1}],'dateformat',options.dateformat);
        title('Weighted contributions');
        legend(label{2:end-1},'Location','Best');
        ax(end+1) = gca();
        pos = pos + 1;
    end
    
    % residuals panel
    if any(options.panels == 3)
        subplot(npanel,1,pos);
        bar(plotrng,x{end},'dateformat',options.dateformat);
        title(label{end});
        ax(end+1) = gca();
        pos = pos + 1;
    end
    
    % equalise ylims in 1st and 3rd panels
    %ylim = [get(ax(1),'YLim'),get(ax(3),'YLim')];
    %set(ax([1,3]),'YLim',[min(ylim),max(ylim)],'YLimMode','Manual');
    
    % grid
    if options.grid
        freq = get(x{1},'freq');
        if freq == 0
            freq = 1;
        end
        stretch = 0.5/freq;
        for axi = ax
            axes(axi);
            ylim = get(axi,'YLim');
            hold('on');
            xticks = dat2dec(plotrng);
            for i = xticks(1:end-1)+stretch
                plot([i,i],ylim,'Color',0.5*[1,1,1],'LineStyle',':','LineWidth',1/2);
            end
            hold('off');
            set(axi,'YGrid','on','TickLength',[0,0]);
        end
    end
    
    % highlight if requested
    if ~isempty(options.highlight)
        highlight(ax,options.highlight,'bar',true);
    end
    
    % title
    if ~isempty(options.title)
        ctitle(options.title);
    end
    
    % checksum
    chksum = x{1} - sum([x{2:end}],2);
    ans = maxabs(chksum);
    if ~isempty(ans) && ans > tol && options.warning
        warning('Max of check-sum significantly greater than zero: %g.',ans);
    end
    
end
function [LegeEntry,H,Time,Data,Grid] = plot(This,Ax)
% plot  [Not a public function] Draw report/series object.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

par = This.parent;

dateOptions = {
    'dateTick=',par.options.datetick, ...
    'dateFormat=',par.options.dateformat, ...
    'freqLetters=',par.options.freqletters, ...
    'months=',par.options.months, ...
    'standinMonth=',par.options.standinmonth, ...
    };

if size(This.data{1}(:,:),2) > 0
    
    switch char(This.options.plotfunc)
        case 'plotcmp'
            % axes(ax);
            [~,H,rr,lhsRange,lhsData,lhsGrid, ...
                rhsRange,rhsData] = ...
                plotcmp(par.options.range,This.data{1}, ...
                dateOptions{:}, ...
                This.options.plotoptions{:}); %#ok<NASGU,ASGLU>
            Time = lhsRange;
            Data = lhsData;
            Grid = lhsGrid;
        case {'predplot','plotpred'}
            [H,~,~,Time,Data,Grid] = plotpred( ...
                Ax,par.options.range, ...
                This.data{1}{:,1}, ...
                This.data{1}{:,2:end}, ...
                dateOptions{:}, ...
                This.options.plotoptions{:});
        otherwise
            [H,Time,Data,Grid] = tseries.myplot( ...
                This.options.plotfunc, ...
                Ax,par.options.range,This.data{1}, ...
                dateOptions{:}, ...
                This.options.plotoptions{:});
    end
    
    % Create legend entries.
    nData = size(Data,2);
    [LegeEntry,exclude] = mylegend(This,nData);
    if exclude && ~isempty(H)
        grfun.excludefromlegend(H);
    end
    
else
    
    % No data plotted.
    H = [];
    Time = [];
    Data = [];
    Grid = [];
    LegeEntry = {};
    
end

end
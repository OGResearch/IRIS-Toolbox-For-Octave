function [LegEnt,Exclude] = mylegend(This,NData)
% mylegend  [Not a public function] Create legend entries for report/series.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

try
    isequaln(0,0);
    isequalnFunc = @isequaln;
catch
    isequalnFunc = @isequalwithequalnans;
end

Exclude = false;

% The default legend entries (created when `'legend=' @auto`) consist of
% the series caption and a mark, unless the legend entries are supplied
% through the `'legend='` option.
if isequal(This.options.legendentry,@auto) ...
        || isequal(This.options.legendentry,Inf)
    
    % ##### May 2014 OBSOLETE and scheduled for removal.
    if isequal(This.options.legendentry,Inf)
        utils.warning('obsolete', ...
            ['Using Inf to create automatic legend entries is obsolete, ',...
            'and this syntax will be removed from IRIS in a future release. ', ...
            'Use @auto instead.']);
    end
    
    % Produce default legend entries.
    LegEnt = cell(1,NData);
    for i = 1 : NData
        name = This.caption;
        if i <= numel(This.options.marks)
            mark = This.options.marks{i};
        else
            mark = '';
        end
        if ~isempty(name) && ~isempty(mark)
            LegEnt{i} = [name,': ',mark];
        elseif isempty(mark)
            LegEnt{i} = name;
        elseif isempty(name)
            LegEnt{i} = mark;
        end
    end
elseif isequalnFunc(This.options.legendentry,NaN)
    % Exclude the series from legend.
    LegEnt = {};
    Exclude = true;
else
    % Use user-suppied legend entries.
    LegEnt = cell(1,NData);
    if ischar(This.options.legendentry)
        This.options.legendentry = {This.options.legendentry};
    end
    This.options.legendentry = This.options.legendentry(:).';
    n = min(length(This.options.legendentry),NData);
    LegEnt(1:n) = This.options.legendentry(1:n);
    LegEnt(n+1:end) = {''};
end

end

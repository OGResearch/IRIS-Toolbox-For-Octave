function [LegendEntry,Exclude] = mylegend(This,NData)
% mylegend  [Not a public function] Create legend entries for report/series.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

Exclude = false;

% The default legend entries (created when `'legend=' Inf`) consist of the
% series caption and a mark, unless the legend entries are supplied through
% the `'legend='` option.
if isequal(This.options.legend,Inf)
    % Produce default legend entries.
    LegendEntry = cell(1,NData);
    for i = 1 : NData
        name = This.caption;
        if i <= numel(This.options.marks)
            mark = This.options.marks{i};
        else
            mark = '';
        end
        if ~isempty(name) && ~isempty(mark)
            LegendEntry{i} = [name,': ',mark];
        elseif isempty(mark)
            LegendEntry{i} = name;
        elseif isempty(name)
            LegendEntry{i} = mark;
        end
    end
elseif isequalwithequalnans(This.options.legend,NaN)
    % Exclude the series from legend.
    LegendEntry = {};
    Exclude = true;
else
    % Use user-suppied legend entries.
    LegendEntry = cell(1,NData);
    if ischar(This.options.legend)
        This.options.legend = {This.options.legend};
    end
    This.options.legend = This.options.legend(:);
    n = min(length(This.options.legend),NData);
    LegendEntry(1:n) = This.options.legend(1:n);
    LegendEntry(n+1:end) = {''};
end

end
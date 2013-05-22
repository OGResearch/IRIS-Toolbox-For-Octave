function TTrend = myrange2ttrend(This,Range)
% myrange2ttrend  [Not a public function] Linear time trend for deterministic trend equations.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isempty(Range)
    TTrend = Range;
else
    freq = datfreq(Range(1));
    if freq == 0
        TTrend = Range;
    else
        if isempty(This.torigin)
            torigin = datcode(freq,2000,1);
        else
            torigin = datcode(freq,round(This.torigin),1);
        end
        TTrend = floor(Range - torigin);
    end
end

end

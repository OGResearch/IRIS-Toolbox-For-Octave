function [This,S,Shift] = mylagorlead(This,S)
% mylagorlead  [Not a public function] Shift time series by a lag or lead.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

if strcmp(S(1).type,'{}') && ...
        length(S(1).subs) == 1 && ...
        length(S(1).subs{1}) == 1 && ...
        round(S(1).subs{1}) == S(1).subs{1} && ...
        ~isinf(S(1).subs{1})

    if datfreq(This.start) == 0 ...
            && (length(S) == 1 || ~any(strcmp(S(2).type,{'{}','()'})))
        utils.error('tseries', ...
            ['Cannot disambiguate this {}-reference to tseries object ', ...
            'with indeterminate frequency. ', ...
            'Use an explicit double {}-reference X{LagOrLead}{Date}.']);
    end
    
    Shift = S(1).subs{1};
    This.start = This.start - Shift;
    S(1) = [];
else
    Shift = 0;
end

end
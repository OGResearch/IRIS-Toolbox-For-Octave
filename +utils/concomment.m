function C = concomment(To,From,IsLog)
% concomment  [Not a public function] Text string for contributions comments.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

try
    IsLog; %#ok<VUNUS>
catch
    IsLog = false;
end

% Handle cell inputs.
if iscellstr(To) || iscellstr(From)
    if ischar(To)
        To = {To};
    end
    if ischar(From)
        From = {From};
    end
    nTo = numel(To);
    nFrom = numel(From);
    n = max(nTo,nFrom);
    C = cell(1,n);
    for i = 1 : n
        C{i} = utils.concomment(To{min(i,end)},From{min(i,end)},IsLog);
    end
    return
end
    
%--------------------------------------------------------------------------

if ~IsLog
    % Additive contributions.
    sign = '+';
else
    % Multiplicative contributions.
    sign = '*'; 
end

ptn = '%s <--[%s] %s';
C = sprintf(ptn,To,sign,From);

end

function C = concomment(To,From,IsLog)
% concomment  [Not a public function] Text string for contributions comments.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

try
    IsLog; %#ok<VUNUS>
catch
    IsLog = false;
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

function [Phi,Psi,S,C] = ferf(This,Time)
% ferf  Forecast error response function.
%
% Syntax
% =======
%
%     [Phi,Psi,s,c] = ferf(V,NPer)
%     [Phi,Psi,s,c] = ferf(V,Range)
%
% Input arguments
% ================
%
% * `V` [ VAR ] - VAR object for which the forecast error response function
% will be computed.
%
% * `NPer` [ numeric ] - Number of periods.
%
% * `Range` [ numeric ] - Date range.
%
% Output arguments
% =================
%
% * `Phi` [ numeric ] - Response function matrices.
%
% * `Psi` [ numeric ] - Cumulative response function matrices.
%
% * `S` [ tseries ] - Response function time series.
%
% * `C` [ tseries ] - Cumulative response function time series.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

% Tell if `time` is `nper` or `range`.
if length(Time) == 1 && round(Time) == Time && Time > 0
    range = 1 : Time;
else
    range = Time(1) : Time(end);
end
nPer = length(range);

%--------------------------------------------------------------------------

% Compute VMA matrices.
Phi = timedom.var2vma(This.A,[],nPer);

if nargout > 1
    % Cumulative responses.
    Psi = cumsum(Phi,3);
    if nargout > 2
        % Create tseries objects.
        S = permute(Phi,[3,1,2,4]);
        S = tseries(range,S);
        if nargout > 3
            C = permute(Psi,[3,1,2,4]);
            C = replace(S,C);
        end
    end
end

end
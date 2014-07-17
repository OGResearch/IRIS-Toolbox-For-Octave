function X = apct(X,Q)
% apct  Annualised percent rate of change.
%
% Syntax
% =======
%
%     X = apct(X)
%
% Input arguments
% ================
%
% * `X` [ tseries ] - Input tseries object.
%
% Output arguments
% =================
%
% * `X` [ tseries ] - Annualised percentage rate of change in the input
% data.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

try
    Q; %#ok<VUNUS>
catch %#ok<CTCH>
    Q = datfreq(X.start);
    if Q == 0
        Q = 1;
    end
end

pp = inputParser();
pp.addRequired('Q',@isnumericscalar);
pp.parse(Q);

%--------------------------------------------------------------------------

X = unop(@tseries.mypct,X,0,-1,Q);

end

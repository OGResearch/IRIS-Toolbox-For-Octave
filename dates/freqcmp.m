function Flag = freqcmp(X,Y)
% freqcmp  Compare date frequencies.
%
% Syntax
% =======
%
%     Flag = freqcmp(D1,D2)
%
% Input arguments
% ================
%
% * `D1`, `D2` [ numeric ] - IRIS serial date numbers.
%
% Output arguments
% =================
%
% * `Flag` [ `true` | `false` ] - True for dates of the same frequency.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

XInf = isinf(X);
YInf = isinf(Y);

fx = X - floor(X);
fx(XInf) = Inf;
fy = Y - floor(Y);
fy(YInf) = Inf;

Flag = abs(fx - fy) < 1e-2 | isinf(fx - fy);

end

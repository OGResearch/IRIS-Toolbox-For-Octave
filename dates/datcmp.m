function Flag = datcmp(Dat1,Dat2)
% datcmp  Compare two IRIS serial date numbers.
%
% Syntax
% =======
%
%     Flag = datcmp(Dat1,Dat2)
%
% Input arguments
% ================
%
% * `Dat1`, `Dat2` [ numeric ] - IRIS serial date numbers or vectors.
%
% Output arguments
% =================
%
% * `Flag` [ `true` | `false` ] - True for numbers that represent the same
% date.
%
% Description
% ============
%
% The two date vectors must either be the same lengths, or one of them must
% be scalar.
%
% Use this function instead of the plain comparison operator, `==`, to
% compare dates. The plain comparision can sometimes give false results
% because of round-off errors.
%
% Example
% ========
%
%     d1 = qq(2010,1);
%     d2 = qq(2009,1):qq(2010,4);
%     datcmp(d1,d2)
%     ans =
%         0     0     0     0     1     0     0     0

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

% Parse required input arguments.
pp = inputParser();
pp = pp.addRequired('D1',@isnumeric);
pp = pp.addRequired('D2',@isnumeric);
pp = pp.parse(Dat1,Dat2);

%--------------------------------------------------------------------------

Flag = abs(Dat1 - Dat2) < 0.01 | (isinf(Dat1) & isinf(Dat2));

end

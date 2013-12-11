function Flag = rngcmp(R1,R2)
% rngcmp  Compare two IRIS date ranges.
%
% Syntax
% =======
%
%     Flag = rngcmp(R1,R2)
%
% Input arguments
% ================
%
% * `R1`, `R2` [ numeric ] - Two IRIS date ranges that will be compared.
%
% Output arguments
% =================
%
% * `Flag` [ `true` | `false` ] - True if the two date ranges are the same.
%
% Description
% ============
%
% An IRIS date range is distinct from a vector of dates in that only the
% first and the last dates matter. Often, date ranges are context
% sensitive. In that case, you can use `-Inf` for the start date (meaning
% the earliest possible date in the given context) and `Inf` for the end
% date (meaning the latest possible date in the given context), or simply
% `Inf` for the whole range (meaning from the earliest possible date to the
% latest possible date in the given context).
%
% Example
% ========
%
%     r1 = qq(2010,1):qq(2020,4);
%     r2 = [qq(2010,1),qq(2020,4)];
%   
%     rngcmp(r1,r2)
%     ans =
%         1
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

% Parse required input arguments.
pp = inputParser();
pp.addRequired('R1',@isnumeric);
pp.addRequired('R2',@isnumeric);
pp.parse(R1,R2);

%--------------------------------------------------------------------------

if isempty(R1) || isempty(R2)
    Flag = isempty(R1) && isempty(R2);
    return
end

Flag = datcmp(R1(1),R2(1)) && datcmp(R1(end),R2(end));

end
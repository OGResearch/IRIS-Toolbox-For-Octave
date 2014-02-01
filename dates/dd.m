function Dat = dd(Year,Month,Day)
% dd  Matlab serial date numbers that can be used to construct daily tseries objects.
%
% Syntax
% =======
%
%     Dat = dd(Year,Month,Day)
%
% Output arguments
% =================
%
% * `Dat` [ numeric ] - IRIS serial date numbers.
%
% Input arguments
% ================
%
% * `Year` [ numeric ] - Years.
%
% * `Month` [ numeric ] - Months.
%
% * `Day` [ numeric ] - Days.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

if nargin < 2
    Month = 1;
end

if nargin < 3
    Day = 1;
elseif strcmpi(Day,'end')
    Day = eomday(Year,Month);
end

Dat = datenum(Year,Month,Day);

end

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
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

if nargin < 2
   Month = 1;
end

if nargin < 3
   Day = 1;
elseif strcmpi(Day,'end')
   Day = eomday(Year,Month);
end

Year = Year(:);
Month = Month(:);
Day = Day(:);

nYear = length(Year);
nMonth = length(Month);
nDay = length(Day);

n = max([nYear,nMonth,nDay]);
if n > 1
   if nYear == 1
      Year = Year(ones([n,1]));
   end
   if nMonth == 1
      Month = Month(ones([n,1]));
   end
   if nDay == 1
      Day = Day(ones([n,1]));
   end
end

Dat = datenum([Year,Month,Day]);

end

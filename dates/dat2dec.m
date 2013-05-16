function dec = dat2dec(dat)
% dat2dec  Convert dates to their decimal representations.
%
% Syntax
% =======
%
%     DEC = dat2dec(DAT)
%
% Input arguments
% ================
%
% * `DAT` [ numeric ] - IRIS serial date number.
%
% Output arguments
% =================
%
% * `DEC` [ numeric ] - Decimal number representing the input dates,
% computed as `year + (per-1)/freq`.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%**************************************************************************

[year,per,freq] = dat2ypf(dat);

if freq == 0
   dec = per;
else
   dec = year + (per-1)./freq;
end

end

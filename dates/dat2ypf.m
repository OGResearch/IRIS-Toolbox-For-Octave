function [year,per,freq] = dat2ypf(dat)
% dat2ypf  Convert IRIS serial date number to year, period and frequency.
%
% Syntax
% =======
%
%     [y,p,f] = dat2ypf(dat)
%
% Input arguments
% ================
%
% * `dat` [ numeric ] - IRIS serial date numbers.
%
% Output arguments
% =================
%
% * `y` [ numeric ] - Years.
%
% * `p` [ numeric ] - Periods within year.
%
% * `f` [ numeric ] - Date frequencies.
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

yp = floor(dat);
freq = datfreq(dat);
index = freq == 0;

[year,per] = deal(nan(size(dat)));

% Determinate frequencies.
year(~index)  = floor(yp(~index) ./ freq(~index));
per(~index) = round(yp(~index) - year(~index).*freq(~index) + 1);

% Indeterminate frequency.
year(index) = 0;
per(index) = dat(index); 

end

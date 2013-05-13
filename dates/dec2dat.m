function dat = dec2dat(dec,freq)
% dec2dat  Convert decimal numbers to IRIS serial date numbers.
%
% Syntax
% =======
%
%     dat = dec2dat(dec,freq)
%
% Input arguments
% ================
%
% * `dec` [ numeric ] - Decimal numbers representing dates.
%
% * `freq` [ freq ] - Date frequency.
%
% Output arguments
% =================
%
% * dat [ numeric ] - IRIS serial data numbers corresponding to the input
% decimals.


% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%**************************************************************************

if length(freq) == 1, freq = freq*ones(size(dec)); end

if freq == 0
   dat = dec;
else
   year = floor(dec);
   per = round((dec - year) .* freq) + 1;
   dat = datcode(freq,year,per);
end

end

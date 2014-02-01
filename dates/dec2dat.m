function Dat = dec2dat(Dec,Freq,Pos)
% dec2dat  Convert decimal representation of date to IRIS serial date number.
%
% Syntax
% =======
%
%     Dat = dec2dat(Dec,Freq)
%
% Input arguments
% ================
%
% * `Dec` [ numeric ] - Decimal numbers representing dates.
%
% * `Freq` [ freq ] - Date frequency.
%
% Output arguments
% =================
%
% * Dat [ numeric ] - IRIS serial date numbers corresponding to the decimal
% representations `Dec`.
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
    Pos; %#ok<VUNUS>
catch
    Pos = 's';
end
Pos = lower(Pos(1));

%--------------------------------------------------------------------------

if length(Freq) == 1
    Freq = Freq*ones(size(Dec));
end

ixZero = Freq == 0;
ixWeekly = Freq == 52;
ixRegular = ~ixZero & ~ixWeekly;

Dat = nan(size(Dec));

% Regular frequencies
%---------------------
if any(ixRegular(:))
    switch Pos
        case {'s','b'}
            adjust = -1;
        case {'c','m'}
            adjust = -1/2;
        case {'e'}
            adjust = 0;
        otherwise
            adjust = -1;
    end    
    year = floor(Dec(ixRegular));
    per = round((Dec(ixRegular) - year) .* Freq(ixRegular) - adjust);
    Dat(ixRegular) = datcode(Freq(ixRegular),year,per);
end

% Weekly frequency
%------------------
if any(ixWeekly(:))
    x = dec2day(Dec(ixWeekly));
    Dat(ixWeekly) = day2ww(x);
end

% Indeterminate frequency
%-------------------------
if any(ixZero(:))
    Dat(ixZero) = Dec(ixZero);
end

end

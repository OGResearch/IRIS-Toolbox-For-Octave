function Dat = ww(Year,varargin)
% ww  IRIS serial date number for weekly date.
%
% Syntax
% =======
%
%     Dat = ww(Year,Week)
%     Dat = ww(Year,Month,Day)
%
% Input arguments
% ================
%
% * `Year` [ numeric ] - Years.
%
% * `Week` [ numeric ] - Week of the year.
%
% * `Month` [ numeric ] - Calendar month.
%
% * `Day` [ numeric ] - Calendar day of the month `Month`.
%
% Output arguments
% =================
%
% * `Dat` [ numeric ] - IRIS serial date number representing the weekly
% date.
%
% Description
% ============
%
% The IRIS weekly dates comply with the ISO 8601 definition:
%
% * every week starts on Monday and ends on Sunday;
%
% * the month or year to which the week belongs is determined by its
% Thurdsay.
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

if isempty(varargin)
    % Monday in the first week of the year.
    x = fwymonday(Year);
elseif length(varargin) == 1
    % Year, week.
    per = varargin{1};
    if isequal(per,'end')
        per = weeksinyear(Year);
    end
    x = fwymonday(Year);
    x = x + 7*(per-1);
else
    % Year, month, day.
    x = datenum(Year,varargin{1},varargin{2});
end
Dat = day2ww(x);

end
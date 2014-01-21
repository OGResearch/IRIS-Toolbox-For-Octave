function [Year,Per,Freq] = day2ypfweekly(X)
% day2ypfweekly  [Not a public function] Convert Matlab serial number representing Monday in a week to
% YPF.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

Per = nan(size(X));
Freq = 52*ones(size(X));

% Calendar year.
[Year,~] = datevec(X);

% Matlab serial number for Monday in the first week of the year, and for
% Sunday in the last week of the year.
first = fwymonday(Year);
last = lwysunday(Year);

ixBefore = X < first;
if any(ixBefore)
    % This day is in the last week of the previous year.
    Year(ixBefore) = Year(ixBefore) - 1;
    % Get the number of weeks in this Year-1.
    Per(ixBefore) = weeksinyear(Year(ixBefore));
end

ixAfter = X > last;
if any(ixAfter)
    % This day is in the first week of the next year.
    Year(ixAfter) = Year(ixAfter) + 1;
    Per(ixAfter) = 1;
end

ixWithin = ~ixBefore & ~ixAfter;
if any(ixWithin)
    Per(ixWithin) = floor((X(ixWithin) - first(ixWithin))/7) + 1;
end

end
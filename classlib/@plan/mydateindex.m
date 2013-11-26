function [x,outofrange] = mydateindex(this,dates)
% MYDATEINDEX [Not a public function] Check user dates against plan range.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%**************************************************************************

nper = round(this.endDate - this.startDate + 1);
x = round(dates - this.startDate + 1);
outofrangeindex = x < 1 | x > nper;
outofrange = dates(outofrangeindex);
x(outofrangeindex) = NaN;

end
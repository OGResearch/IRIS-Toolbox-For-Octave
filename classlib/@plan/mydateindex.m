function [x,outofrange] = mydateindex(this,dates)
% MYDATEINDEX [Not a public function] Check user dates against plan range.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%**************************************************************************

nper = round(this.End - this.Start + 1);
x = round(dates - this.Start + 1);
outofrangeindex = x < 1 | x > nper;
outofrange = dates(outofrangeindex);
x(outofrangeindex) = NaN;

end
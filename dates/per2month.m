function m = per2month(p,f,standinmonth)
% per2month  [Not a public function] Return month to represent a given period.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%**************************************************************************

if ischar(standinmonth)
    switch standinmonth
        case {'first','start'}
            standinmonth = 1;
        case {'last','end'}
            standinmonth = 12/f;
        otherwise
            standinmonth = 1;
    end
end

m = (p-1).*12./f + standinmonth;

end
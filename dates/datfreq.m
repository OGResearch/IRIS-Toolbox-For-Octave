function freq = datfreq(dat)
% datfreq  Frequency of IRIS serial date numbers.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%--------------------------------------------------------------------------

freq = round(100*(dat - floor(dat)));

end

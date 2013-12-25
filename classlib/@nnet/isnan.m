function out = isnan(This) 

% isnan  []
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

params = get(This,'params') ;
if any(isnan(params))
    out = true ;
else
    out = false ;
end

end


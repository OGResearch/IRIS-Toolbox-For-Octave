function out = isnan(This) 

% isnan  []
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

params = [...
    get(This,'activation'); ...
    get(This,'output'); ...
    get(This,'hyper'); ...
    ];

if any(isnan(params))
    out = true ;
else
    out = false ;
end

end


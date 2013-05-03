function x = mynansum(x,dim)
% mynansum  [Not a public function] Sum implemented for data with in-sample NaNs.
%
%
% Backed IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%**************************************************************************

if dim > ndims(x)
    return
end
index = ~isnan(x);
x(~index) = 0;
x = sum(x,dim);

end
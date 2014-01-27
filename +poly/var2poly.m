function A = var2poly(A)
% var2poly  Convert VAR style matrix to 3D polynomial.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%**************************************************************************

if isvar(A)
   A = get(A,'A');
end
[ny,p,nalt] = size(A);
p = p/ny;
x = eye(ny);
x = x(:,:,1,ones([1,nalt]));
A = cat(3,x,reshape(-A,[ny,ny,p,nalt]));

end

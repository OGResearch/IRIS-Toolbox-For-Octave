function A = poly2var(A)
% poly2var  Convert 3D polynomial to VAR style matrix.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%**************************************************************************

[ny,ny,p,nalt] = size(A);
p = p - 1;
for ialt = 1 : nalt
   if any(A(:,:,1,ialt) ~= eye(ny))
      error('Polynomial must be monic.');
   end
end
A = reshape(-A(:,:,2:end,:),[ny,ny*p,nalt]);

end

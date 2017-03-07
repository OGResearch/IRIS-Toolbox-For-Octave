function [Phi,icsize] = icrf(T,R,K,Z,H,D,U,Omega,nper,icsize,icindex) %#ok<INUSL>
% icrf  [Not a public function] Response function to initial condition for general state space.
%
% Backend IRIS function.
% No help provided.

% -IRIS Toolbox.
% -Copyright (c) 2007-2014 IRIS Solutions Team.

%**************************************************************************

ny = size(Z,1);
[nx,nb] = size(T);
nf = nx - nb;

Phi = zeros(ny+nx,nb,nper+1);
Phi(ny+nf+1:end,:,1) = diag(icsize);
if ~isempty(U)
   Phi(ny+nf+1:end,:,1) = U\Phi(ny+nf+1:end,:,1);
end

for t = 2 : nper + 1
   Phi(ny+1:end,:,t) = T*Phi(ny+nf+1:end,:,t-1);
   if ny > 0
      Phi(1:ny,:,t) = Z*Phi(ny+nf+1:end,:,t);
   end
end

if ~isempty(U)
   for t = 1 : nper+1
      Phi(ny+nf+1:end,:,t) = U*Phi(ny+nf+1:end,:,t);
   end
end

% Select responses to true initial conditions only.
Phi = Phi(:,icindex,:,:);

end
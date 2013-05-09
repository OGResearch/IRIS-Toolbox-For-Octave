function [T,R,k,Z,H,d,U,Omg,Alt] = sspace(This,varargin)
% sspace  Quasi-triangular state-space representation of VAR.
%
% Syntax
% =======
%
%     [T,R,K,Z,H,D,Omg] = sspace(V,...)
%
% Input arguments
% ================
%
% * `V` [ VAR ] - VAR object.
%
% Output arguments
% =================
%
% * `T` [ numeric ] - Transition matrix.
%
% * `R` [ numeric ] - Matrix at the shock vector in transition equations.
%
% * `K` [ numeric ] - Constant vector in transition equations.
%
% * `Z` [ numeric ] - Matrix mapping transition variables to measurement
% variables.
%
% * `H` [ numeric ] - Matrix at the shock vector in measurement
% equations.
%
% * `D` [ numeric ] - Constant vector in measurement equations.
%
% * `U` [ numeric ] - Transformation matrix for predetermined variables.
%
% * `Omega` [ numeric ] - Covariance matrix of shocks.
%
% Description
% ============
%
% Example
% ========
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

if ~isempty(varargin) && isnumericscalar(varargin{1}) 
   Alt = varargin{1};
   varargin(1) = []; %#ok<NASGU>
else
   Alt = ':';
end

%--------------------------------------------------------------------------

ny = size(This.A,1);
p = size(This.A,2) / max(ny,1);

T = This.T(:,:,Alt);
U = This.U(:,:,Alt);
R = permute(U(1:ny,:,:),[2,1,3]);
K = This.K(:,:,Alt);
n3 = size(T,3);

% Constant term.
k = repmat(zeros(size(K)),p,1);
for i = 1 : n3
   k(:,:,i) = transpose(U(1:ny,:,i))*K(:,:,i);
end

Z = U(1:ny,:,:);

H = zeros(ny,ny,n3);
d = zeros(ny,1,n3);

Omg = This.Omega(:,:,Alt);

end
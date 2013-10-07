function [T,R,k,Z,H,d,U,Omg] = sspace(This,varargin)
% sspace  Quasi-triangular state-space form for VAR.
%
% Syntax
% =======
%
%     [T,R,K,Z,H,D,Omg] = sspace(w,...)
%
% Input arguments
% ================
%
% * `w` [ VAR ] - VAR object.
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
% Syntax
% =======
%

% -IRIS Toolbox.
% -Copyright (c) 2007-2013 IRIS Solutions Team.

%--------------------------------------------------------------------------

[T,R,k,Z,H,d,U,~,alt] = sspace@VAR(This,varargin{:});
ny = size(This.A,1);
n3 = size(T,3);

% Structural VAR.
B = This.B(:,:,alt);
for i = 1 : n3
   R(:,:,i) = R(:,:,i)*B(:,:,i);
end

% Covariance matrix of structural residuals.
varVec = This.std(alt) .^ 2;
Omg = eye(ny);
Omg = Omg(:,:,ones([1,n3]));
for i = 1 : n3
   Omg(:,:,i) = Omg(:,:,i) * varVec(i);
end

end